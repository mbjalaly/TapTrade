import axios, { AxiosError } from 'axios';

// Environment variables - read lazily to ensure dotenv has loaded
const getApiKey = () => process.env.UNOSEND_API_KEY;
const getBaseUrl = () => process.env.UNOSEND_BASE_URL || 'https://www.unosend.co/api';

// Request timeout
const REQUEST_TIMEOUT = 10000; // 10 seconds

// Response types
export interface SendOtpResponse {
  success: boolean;
  verification_id?: string;
  expires_at?: string;
  message?: string;
  error?: string;
  fallback_needed?: boolean;
}

export interface VerifyOtpResponse {
  success: boolean;
  message?: string;
  error?: string;
  attempts_remaining?: number;
  fallback_needed?: boolean;
}

/**
 * Send OTP via UnoSend SMS API
 * @param phone - Phone number in E.164 format (e.g., +14155551234)
 * @param template - Optional custom SMS template (must include {code} placeholder)
 * @returns SendOtpResponse
 */
export async function sendOtp(phone: string, template?: string): Promise<SendOtpResponse> {
  try {
    // Validate API key
    if (!getApiKey()) {
      console.error('[UnoSend] API key not configured');
      return {
        success: false,
        error: 'SMS service not configured',
        fallback_needed: true
      };
    }

    // Validate phone number format (E.164)
    if (!phone.match(/^\+[1-9]\d{1,14}$/)) {
      console.error('[UnoSend] Invalid phone format:', phone);
      return {
        success: false,
        error: 'Invalid phone number format. Please use E.164 format (e.g., +14155551234)'
      };
    }

    console.log(`[UnoSend] Sending OTP to ${phone}`);

    // Make API request
    const response = await axios.post(
      `${getBaseUrl()}/v1/sms/verify/send`,
      {
        phone: phone,  // UnoSend API uses 'phone' not 'phone_number'
        template: template || 'Tap Trade verification code is: {code}',  // Custom SMS template
        expiry_minutes: 3  // Code expires in 10 minutes
      },
      {
        headers: {
          'Authorization': `Bearer ${getApiKey()}`,
          'Content-Type': 'application/json'
        },
        timeout: REQUEST_TIMEOUT
      }
    );

    console.log('[UnoSend] OTP sent successfully:', response.data);

    // Response format: { id: "ver_abc123", phone: "+...", status: "sent", expires_at: "ISO8601" }
    return {
      success: true,
      verification_id: response.data.id,  // UnoSend returns 'id' not 'verification_id'
      expires_at: response.data.expires_at,
      message: 'OTP sent successfully'
    };

  } catch (error) {
    console.error('[UnoSend] Error sending OTP:', error);

    // Handle axios errors
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<any>;

      // Network/timeout errors
      if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
        console.error('[UnoSend] Request timeout');
        return {
          success: false,
          error: 'SMS service timeout. Please try again.',
          fallback_needed: true
        };
      }

      // API errors
      if (axiosError.response) {
        const status = axiosError.response.status;
        const data = axiosError.response.data;

        console.error(`[UnoSend] API error ${status}:`, data);

        // Unauthorized
        if (status === 401) {
          return {
            success: false,
            error: 'SMS service authentication failed',
            fallback_needed: true
          };
        }

        // Rate limiting
        if (status === 429) {
          return {
            success: false,
            error: data.message || 'Too many requests. Please try again later.'
          };
        }

        // Other API errors
        return {
          success: false,
          error: data.message || 'Failed to send OTP. Please try again.',
          fallback_needed: status >= 500 // Server errors should trigger fallback
        };
      }

      // No response received
      console.error('[UnoSend] No response from API');
      return {
        success: false,
        error: 'SMS service unavailable',
        fallback_needed: true
      };
    }

    // Unknown errors
    return {
      success: false,
      error: 'Unexpected error occurred',
      fallback_needed: true
    };
  }
}

/**
 * Verify OTP via UnoSend SMS API
 * @param phone - Phone number in E.164 format
 * @param code - 6-digit OTP code
 * @returns VerifyOtpResponse
 */
export async function verifyOtp(phone: string, code: string): Promise<VerifyOtpResponse> {
  try {
    // Validate API key
    if (!getApiKey()) {
      console.error('[UnoSend] API key not configured');
      return {
        success: false,
        error: 'SMS service not configured',
        fallback_needed: true
      };
    }

    // Validate phone number format
    if (!phone.match(/^\+[1-9]\d{1,14}$/)) {
      console.error('[UnoSend] Invalid phone format:', phone);
      return {
        success: false,
        error: 'Invalid phone number format'
      };
    }

    // Validate OTP code (6 digits)
    if (!code.match(/^\d{6}$/)) {
      console.error('[UnoSend] Invalid OTP code format');
      return {
        success: false,
        error: 'Invalid OTP code. Please enter a 6-digit code.'
      };
    }

    console.log(`[UnoSend] Verifying OTP for ${phone}`);

    // Make API request
    const response = await axios.post(
      `${getBaseUrl()}/v1/sms/verify/check`,
      {
        phone: phone,  // UnoSend API uses 'phone' not 'phone_number'
        code: code
      },
      {
        headers: {
          'Authorization': `Bearer ${getApiKey()}`,
          'Content-Type': 'application/json'
        },
        timeout: REQUEST_TIMEOUT
      }
    );

    console.log('[UnoSend] OTP verified successfully:', response.data);

    // Response format: { valid: true/false, status: "verified"|"invalid"|"expired"|"max_attempts", message: "..." }
    if (response.data.valid === true && response.data.status === 'verified') {
      return {
        success: true,
        message: response.data.message || 'Phone verified successfully'
      };
    } else {
      // Invalid, expired, or max attempts reached
      return {
        success: false,
        error: response.data.message || 'Invalid or expired OTP code',
        attempts_remaining: response.data.status === 'max_attempts' ? 0 : undefined
      };
    }

  } catch (error) {
    console.error('[UnoSend] Error verifying OTP:', error);

    // Handle axios errors
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<any>;

      // Network/timeout errors
      if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
        console.error('[UnoSend] Request timeout');
        return {
          success: false,
          error: 'SMS service timeout. Please try again.',
          fallback_needed: true
        };
      }

      // API errors
      if (axiosError.response) {
        const status = axiosError.response.status;
        const data = axiosError.response.data;

        console.error(`[UnoSend] API error ${status}:`, data);

        // Bad request - could be invalid code, expired, or max attempts
        if (status === 400) {
          // Check if the response has valid/status fields
          if (data.valid === false) {
            return {
              success: false,
              error: data.message || 'Invalid or expired OTP code',
              attempts_remaining: data.status === 'max_attempts' ? 0 : undefined
            };
          }
          return {
            success: false,
            error: data.message || 'Invalid OTP code'
          };
        }

        // Not found - verification session doesn't exist
        if (status === 404) {
          return {
            success: false,
            error: 'Verification session not found. Please request a new code.'
          };
        }

        // Unauthorized
        if (status === 401) {
          return {
            success: false,
            error: 'SMS service authentication failed',
            fallback_needed: true
          };
        }

        // Rate limiting
        if (status === 429) {
          return {
            success: false,
            error: data.message || 'Too many verification attempts. Please try again later.'
          };
        }

        // Other API errors
        return {
          success: false,
          error: data.message || 'Failed to verify OTP. Please try again.',
          fallback_needed: status >= 500
        };
      }

      // No response received
      console.error('[UnoSend] No response from API');
      return {
        success: false,
        error: 'SMS service unavailable',
        fallback_needed: true
      };
    }

    // Unknown errors
    return {
      success: false,
      error: 'Unexpected error occurred',
      fallback_needed: true
    };
  }
}

/**
 * Test UnoSend service health
 * @returns boolean indicating if service is available
 */
export async function testConnection(): Promise<boolean> {
  try {
    if (!getApiKey()) {
      console.error('[UnoSend] API key not configured');
      return false;
    }

    // Simple health check - try to send to a test number
    // In production, you might want a dedicated health endpoint
    console.log('[UnoSend] Testing connection...');
    return true;

  } catch (error) {
    console.error('[UnoSend] Connection test failed:', error);
    return false;
  }
}
