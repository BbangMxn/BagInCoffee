import type { UserProfileSimple } from './user';

export interface Recipe {
    id: string;
    user_id: string;
    title: string;
    ingredients: RecipeIngredients | null;  // JSONB
    instructions: string | null;
    brew_method: string | null;
    brew_time: number | null;
    difficulty: 'easy' | 'medium' | 'hard' | null;
    image_url: string | null;
    likes_count: number;
    created_at: string;
    updated_at: string;
}

// 재료 (JSONB)
export interface RecipeIngredients {
    coffee: {
        amount: number;      // g
        grind_size?: string;
        type?: string;
    };
    water: {
        amount: number;      // ml
        temperature: number; // ℃
    };
    ratio?: string;        // "1:15"
}

// 작성자 정보 포함
export interface RecipeWithAuthor extends Recipe {
    author: UserProfileSimple;
    hasLiked?: boolean;
}

// 레시피 생성 Input
export interface CreateRecipeInput {
    title: string;
    ingredients: RecipeIngredients;
    instructions?: string;
    brew_method?: string;
    brew_time?: number;
    difficulty?: 'easy' | 'medium' | 'hard';
    image_url?: string;
}