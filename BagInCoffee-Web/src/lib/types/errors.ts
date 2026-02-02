// src/lib/server/utils/errors.ts

/**
 * 🎯 기본 에러 클래스
 * 모든 커스텀 에러의 부모 클래스
 */
export class AppError extends Error {
    constructor(
        public statusCode: number,    // HTTP 상태 코드 (400, 401, 404...)
        public message: string,        // 에러 메시지
        public code?: string          // 에러 코드 (VALIDATION_ERROR 등)
    ) {
        super(message);
        this.name = this.constructor.name;  // 에러 이름 = 클래스명
        Error.captureStackTrace(this, this.constructor);  // 스택 추적
    }
}

/**
 * ❌ 400 - 잘못된 요청 (입력값 오류)
 * 사용 예: 빈 게시물 작성 시도, 잘못된 이메일 형식
 */
export class ValidationError extends AppError {
    constructor(message: string) {
        super(400, message, 'VALIDATION_ERROR');
    }
}

/**
 * 🔒 401 - 인증 필요 (로그인 안 됨)
 * 사용 예: 로그인 없이 게시물 작성 시도
 */
export class UnauthorizedError extends AppError {
    constructor(message = '인증이 필요합니다.') {
        super(401, message, 'UNAUTHORIZED');
    }
}

/**
 * 🚫 403 - 권한 없음 (로그인은 했지만 권한 부족)
 * 사용 예: 다른 사람 게시물 삭제 시도
 */
export class ForbiddenError extends AppError {
    constructor(message = '권한이 없습니다.') {
        super(403, message, 'FORBIDDEN');
    }
}

/**
 * 🔍 404 - 찾을 수 없음
 * 사용 예: 존재하지 않는 게시물 조회
 */
export class NotFoundError extends AppError {
    constructor(message = '리소스를 찾을 수 없습니다.') {
        super(404, message, 'NOT_FOUND');
    }
}

/**
 * ⏱️ 429 - 너무 많은 요청
 * 사용 예: 1분에 100번 요청
 */
export class RateLimitError extends AppError {
    constructor(message = '요청 한도를 초과했습니다.') {
        super(429, message, 'RATE_LIMIT');
    }
}

/**
 * 🔧 에러를 HTTP 응답으로 변환
 */
export function errorResponse(error: unknown) {
    console.error('Server Error:', error);

    // 우리가 만든 에러인 경우
    if (error instanceof AppError) {
        return {
            status: error.statusCode,
            body: {
                error: {
                    code: error.code,
                    message: error.message
                }
            }
        };
    }

    // PostgreSQL 에러 (Supabase)
    if (error && typeof error === 'object' && 'code' in error) {
        const pgError = error as { code: string; message: string };

        // 에러 코드별 처리
        const errorMap: Record<string, { status: number; message: string }> = {
            '23505': { status: 409, message: '이미 존재하는 데이터입니다.' },  // 중복
            '23503': { status: 400, message: '참조 데이터가 없습니다.' },      // FK 위반
        };

        const mapped = errorMap[pgError.code];
        if (mapped) {
            return {
                status: mapped.status,
                body: { error: { code: pgError.code, message: mapped.message } }
            };
        }
    }

    // 알 수 없는 에러 → 500
    return {
        status: 500,
        body: { error: { code: 'INTERNAL_SERVER_ERROR', message: '서버 오류' } }
    };
}

/**
 * ✅ 성공 응답 생성
 */
export function successResponse<T>(data: T, status = 200) {
    return {
        status,
        body: {
            success: true,
            data
        }
    };
}