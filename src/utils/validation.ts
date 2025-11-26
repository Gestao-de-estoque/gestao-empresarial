/**
 * Utilitários de validação para o sistema
 */

/**
 * Valida se uma string é um UUID válido
 * @param uuid - String a ser validada
 * @returns true se for um UUID válido, false caso contrário
 */
export function isValidUUID(uuid: string | null | undefined): boolean {
  if (!uuid || uuid.trim() === '') {
    return false
  }

  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
  return uuidRegex.test(uuid)
}

/**
 * Normaliza um UUID para null se for inválido
 * Útil para evitar enviar strings vazias para campos UUID do banco
 * @param uuid - UUID a ser normalizado
 * @returns UUID válido ou null
 */
export function normalizeUUID(uuid: string | null | undefined): string | null {
  if (!uuid || uuid.trim() === '') {
    return null
  }

  return isValidUUID(uuid) ? uuid : null
}

/**
 * Valida um objeto antes de enviar para o banco
 * Remove campos UUID vazios ou inválidos
 * @param data - Objeto a ser validado
 * @param uuidFields - Lista de campos que devem ser UUID
 * @returns Objeto validado com UUIDs normalizados
 */
export function validateAndNormalizeUUIDs<T extends Record<string, any>>(
  data: T,
  uuidFields: (keyof T)[]
): T {
  const validated = { ...data }

  for (const field of uuidFields) {
    const value = validated[field]
    if (typeof value === 'string') {
      validated[field] = normalizeUUID(value) as any
    }
  }

  return validated
}

/**
 * Classe para erros de validação
 */
export class ValidationError extends Error {
  constructor(
    public field: string,
    message: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

/**
 * Valida se um campo UUID é válido e lança erro se não for
 * @param uuid - UUID a ser validado
 * @param fieldName - Nome do campo para mensagem de erro
 * @throws ValidationError se o UUID for inválido
 */
export function requireValidUUID(uuid: string | null | undefined, fieldName: string): void {
  if (!isValidUUID(uuid)) {
    throw new ValidationError(
      fieldName,
      `${fieldName} deve ser um UUID válido`
    )
  }
}

/**
 * Valida se um campo está preenchido
 * @param value - Valor a ser validado
 * @param fieldName - Nome do campo para mensagem de erro
 * @throws ValidationError se o campo estiver vazio
 */
export function requireField<T>(value: T | null | undefined, fieldName: string): asserts value is T {
  if (value === null || value === undefined || (typeof value === 'string' && value.trim() === '')) {
    throw new ValidationError(
      fieldName,
      `${fieldName} é obrigatório`
    )
  }
}

/**
 * Formata mensagens de erro do Supabase para o usuário
 * @param error - Erro do Supabase
 * @returns Mensagem de erro amigável
 */
export function formatSupabaseError(error: any): string {
  if (!error) {
    return 'Erro desconhecido'
  }

  // Erro de UUID inválido
  if (error.code === '22P02') {
    return 'Formato de identificador inválido. Verifique os dados e tente novamente.'
  }

  // Erro de violação de RLS
  if (error.code === 'PGRST301' || error.message?.includes('row-level security')) {
    return 'Você não tem permissão para acessar este recurso.'
  }

  // Erro de tenant não encontrado
  if (error.code === 'P0001' && error.message?.includes('tenant')) {
    return 'Usuário não está associado a nenhuma empresa. Entre em contato com o suporte.'
  }

  // Erro de constraint única (duplicata)
  if (error.code === '23505') {
    const match = error.message?.match(/Key \((.*?)\)=/)
    const field = match ? match[1] : 'registro'
    return `Já existe um ${field} com este valor.`
  }

  // Erro de foreign key (referência não encontrada)
  if (error.code === '23503') {
    return 'Registro relacionado não encontrado. Verifique os dados e tente novamente.'
  }

  // Erro de not null (campo obrigatório vazio)
  if (error.code === '23502') {
    const match = error.message?.match(/column "(.*?)"/)
    const field = match ? match[1] : 'campo obrigatório'
    return `O campo ${field} é obrigatório.`
  }

  // Retorna mensagem do erro se houver
  if (error.message) {
    return error.message
  }

  return 'Erro ao processar a solicitação. Tente novamente.'
}
