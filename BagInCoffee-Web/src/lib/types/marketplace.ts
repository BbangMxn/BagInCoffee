import type { UserProfileSimple } from './user';

// 중고거래 아이템
export interface MarketplaceItem {
	id: string;
	seller_id: string;
	equipment_id: string | null;  // ✅ 추가: 장비 테이블 참조
	seller?: UserProfileSimple;
	title: string;
	description: string | null;    // ✅ 수정: nullable
	price: number;
	condition: 'new' | 'like_new' | 'good' | 'fair' | 'poor';  // ✅ 수정: DB와 일치
	images: string[] | null;       // ✅ 수정: nullable
	location: string | null;       // ✅ 수정: nullable
	status: 'active' | 'reserved' | 'sold';  // ✅ 수정: 'available' → 'active'
	created_at: string;
	updated_at: string;
}

// ✅ 작성 Input
export interface CreateMarketplaceItemInput {
	title: string;
	description?: string;
	price: number;
	equipment_id?: string;
	condition: 'new' | 'like_new' | 'good' | 'fair' | 'poor';
	images?: string[];
	location?: string;
}

// ✅ 판매자 정보 포함
export interface MarketplaceItemWithSeller extends MarketplaceItem {
	seller: UserProfileSimple;
}