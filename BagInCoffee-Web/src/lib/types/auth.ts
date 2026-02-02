// src/lib/types/auth.ts

import type { Session, User } from '@supabase/supabase-js';
import type { UserProfile } from './user';

/**
 * 🔐 로그인 폼 Input
 */
export interface LoginInput {
    email: string;
    password: string;
}

/**
 * 🔐 회원가입 폼 Input
 */
export interface RegisterInput {
    email: string;
    password: string;
    full_name: string;
    username?: string;
}

/**
 * 🔐 비밀번호 재설정 Input
 */
export interface PasswordResetInput {
    email: string;
}

/**
 * 🔐 비밀번호 변경 Input
 */
export interface PasswordUpdateInput {
    current_password: string;
    new_password: string;
}

/**
 * 🔐 회원가입 완료 응답
 * (Session + 새로 생성된 Profile)
 */
export interface RegisterResponse {
    session: Session;
    profile: UserProfile;
}

// ❌ 이런 건 불필요 (Supabase가 이미 제공)
// export interface Session { ... }
// export interface User { ... }