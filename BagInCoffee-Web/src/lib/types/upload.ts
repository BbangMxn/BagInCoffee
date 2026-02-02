// src/lib/types/upload.ts

export interface UploadResponse {
    url: string;
    key: string;
    size: number;
    type: string;
    uploaded_at: string;
}

export interface ImageUploadInput {
    file: File;
    folder: 'posts' | 'profiles' | 'equipment' | 'marketplace';
    compress?: boolean;
}

export interface UploadProgress {
    loaded: number;
    total: number;
    percentage: number;
}