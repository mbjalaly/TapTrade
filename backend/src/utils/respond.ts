export function ok<T>(message: string, data?: T) {
  return { success: true, message, ...(typeof data === 'undefined' ? {} : { data }) };
}

export function err(message: string, statusCode = 400) {
  return { success: false, message, statusCode };
}

