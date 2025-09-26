import { supabase, DB_TABLES } from '@/config/supabase'

export interface ExplorerFilter {
  column: string
  operator: 'eq' | 'neq' | 'gt' | 'gte' | 'lt' | 'lte' | 'ilike' | 'like' | 'is' | 'in' | 'between' | 'contains' | 'notnull'
  value: any
  value2?: any
}

export interface ExplorerQuery {
  table: string
  filters?: ExplorerFilter[]
  searchText?: string
  orderBy?: { column: string; ascending: boolean }
  limit?: number
  offset?: number
}

const COMMON_STRING_COLS = [
  'name', 'nome', 'username', 'email', 'title', 'descricao', 'description', 'category', 'resource', 'action', 'status'
]

export type ColumnKind = 'text' | 'number' | 'date' | 'boolean' | 'json' | 'unknown'
export interface ColumnMeta { name: string; kind: ColumnKind }

export const databaseExplorerService = {
  async getAllTables(): Promise<string[]> {
    try {
      // Tenta RPC (se existir no banco)
      const { data, error } = await supabase.rpc('list_tables')
      if (!error && Array.isArray(data) && data.length) {
        return data as string[]
      }
    } catch {}

    // Fallback: usar tabelas conhecidas do app
    const known = Array.from(new Set(Object.values(DB_TABLES)))
    // Adiciona algumas tabelas prováveis do projeto usadas em serviços
    const extras = ['admin_users', 'categorias', 'produtos', 'support_conversations', 'support_messages']
    return Array.from(new Set([...known, ...extras])).sort()
  },

  async getColumnsMeta(table: string): Promise<ColumnMeta[]> {
    // 1) Tenta RPC com metadados
    try {
      const { data, error } = await supabase.rpc('get_table_columns_meta', { tbl: table })
      if (!error && Array.isArray(data)) {
        // Esperado: [{ name: 'id', data_type: 'uuid' }, ...]
        return (data as any[]).map((c: any) => ({ name: c.name || c.column_name, kind: mapDataTypeToKind(c.data_type || c.udt_name || '') }))
      }
    } catch {}

    // 2) Tenta RPC básica (nomes) e infere tipo pelo primeiro registro
    try {
      let columns: string[] | null = null
      try {
        const { data, error } = await supabase.rpc('get_table_columns', { tbl: table })
        if (!error && Array.isArray(data) && data.length) columns = data as string[]
      } catch {}

      const { data } = await supabase.from(table).select('*').limit(1)
      const sample = Array.isArray(data) ? data[0] : undefined
      const names = columns || (sample ? Object.keys(sample) : [])
      if (names.length) {
        return names.map(n => ({ name: n, kind: inferKindFromSample(n, sample ? sample[n] : undefined) }))
      }
    } catch {}

    // 3) Fallback
    return [
      { name: 'id', kind: 'number' },
      { name: 'name', kind: 'text' },
      { name: 'created_at', kind: 'date' },
      { name: 'updated_at', kind: 'date' }
    ]
  },

  async getColumns(table: string): Promise<string[]> {
    const meta = await this.getColumnsMeta(table)
    return meta.map(m => m.name)
  },

  async query(q: ExplorerQuery): Promise<{ rows: any[]; count?: number }> {
    let s = supabase.from(q.table).select('*', { count: 'exact' })

    // Filtros
    for (const f of q.filters || []) {
      switch (f.operator) {
        case 'eq': s = s.eq(f.column, f.value); break
        case 'neq': s = s.neq(f.column, f.value); break
        case 'gt': s = s.gt(f.column, f.value); break
        case 'gte': s = s.gte(f.column, f.value); break
        case 'lt': s = s.lt(f.column, f.value); break
        case 'lte': s = s.lte(f.column, f.value); break
        case 'ilike': s = s.ilike(f.column, `%${f.value}%`); break
        case 'like': s = s.like(f.column, `%${f.value}%`); break
        case 'is': s = s.is(f.column, f.value); break // null
        case 'notnull': s = s.not(f.column, 'is', null); break
        case 'in': s = s.in(f.column, Array.isArray(f.value) ? f.value : String(f.value).split(',')); break
        case 'between':
          if (f.value !== undefined && f.value2 !== undefined) {
            s = s.gte(f.column, f.value).lte(f.column, f.value2)
          }
          break
        case 'contains':
          try {
            const parsed = typeof f.value === 'string' ? JSON.parse(f.value) : f.value
            s = s.contains(f.column, parsed)
          } catch {
            // fallback: texto
            s = s.ilike(f.column, `%${f.value}%`)
          }
          break
      }
    }

    // Busca rápida
    if (q.searchText && q.searchText.trim()) {
      const ors = COMMON_STRING_COLS.map(c => `${c}.ilike.%${q.searchText}%`).join(',')
      s = s.or(ors)
    }

    // Ordenação
    if (q.orderBy) {
      s = s.order(q.orderBy.column, { ascending: q.orderBy.ascending })
    }

    const limit = q.limit ?? 20
    const offset = q.offset ?? 0
    s = s.range(offset, offset + limit - 1)

    const { data, error, count } = await s
    if (error) throw error
    return { rows: data || [], count: count ?? 0 }
  }
}

function mapDataTypeToKind(dt: string): ColumnKind {
  const t = (dt || '').toLowerCase()
  if (t.includes('int') || t.includes('numeric') || t.includes('double') || t.includes('real') || t.includes('decimal')) return 'number'
  if (t.includes('timestamp') || t.includes('date')) return 'date'
  if (t.includes('bool')) return 'boolean'
  if (t.includes('json')) return 'json'
  return 'text'
}

function inferKindFromSample(name: string, val: any): ColumnKind {
  if (val === null || val === undefined) {
    if (name.endsWith('_at') || name.includes('date')) return 'date'
    if (name.includes('count') || name.includes('qty') || name.includes('price') || name.includes('total')) return 'number'
    return 'unknown'
  }
  const t = typeof val
  if (t === 'number') return 'number'
  if (t === 'boolean') return 'boolean'
  if (t === 'object') return Array.isArray(val) ? 'json' : 'json'
  // string heuristics
  if (/^\d{4}-\d{2}-\d{2}/.test(String(val))) return 'date'
  return 'text'
}
