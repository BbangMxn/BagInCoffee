// ==================== Core Types ====================

// 지원 언어
export type Locale = 'ko' | 'en' | 'ja' | 'es' | 'de';

// 구독 타입
export type SubscriptionType = 'brand' | 'product' | 'category' | 'shop';

// 알림 타입
export type NotificationType = 'new_product' | 'new_discount';

// ==================== Shop ====================

export interface Shop {
	id: number;
	name: string;
	domain: string;
	platform: string | null;
	logo_url: string | null;
	created_at: string;
	updated_at: string;
}

export interface ShopTranslation {
	id: number;
	shop_id: number;
	locale: Locale;
	name: string;
	description: string | null;
	created_at: string;
	updated_at: string;
}

// View: shops_with_translations
export interface ShopWithTranslations extends Shop {
	translations: ShopTranslation[];
	product_count: number;
}

// ==================== Brand ====================

export interface Brand {
	id: number;
	name: string;
	image_url: string | null;
	created_at: string;
	updated_at: string;
}

export interface BrandTranslation {
	id: number;
	brand_id: number;
	locale: Locale;
	name: string;
	description: string | null;
	created_at: string;
	updated_at: string;
}

export interface BrandWithTranslations extends Brand {
	translations: BrandTranslation[];
}

// ==================== Category ====================

export interface Category {
	id: number;
	name: string;
	parent_id: number | null;
	icon: string | null;
	created_at: string;
	updated_at: string;
}

export interface CategoryTranslation {
	id: number;
	category_id: number;
	locale: Locale;
	name: string;
	description: string | null;
	created_at: string;
	updated_at: string;
}

export interface CategoryWithTranslations extends Category {
	translations: CategoryTranslation[];
	children?: CategoryWithTranslations[];
}

// ==================== Product ====================

export interface Product {
	id: number;
	shop_id: number;
	brand_id: number | null;
	category_id: number | null;
	name: string;
	sku: string | null;
	is_deleted: boolean;
	created_at: string;
	updated_at: string;
}

export interface ProductWithDetails extends Product {
	shop?: Shop;
	brand?: Brand;
	category?: Category;
	current_discount?: DiscountInfo;
}

// ==================== Discount ====================

export interface DiscountInfo {
	id: number;
	product_id: number;
	original_price: number;
	discount_price: number;
	discount_rate: number;
	start_at: string;
	end_at: string;
	info_url: string | null;
	thumbnail_url: string | null;
	created_at: string;
	updated_at: string;
}

export interface DiscountWithProduct extends DiscountInfo {
	product: ProductWithDetails;
}

// ==================== Subscriptions ====================

export interface BrandSubscription {
	id: number;
	user_id: string;
	brand_id: number;
	created_at: string;
	updated_at: string;
}

export interface CategorySubscription {
	id: number;
	user_id: string;
	category_id: number;
	created_at: string;
	updated_at: string;
}

export interface ProductSubscription {
	id: number;
	user_id: string;
	product_id: number;
	created_at: string;
	updated_at: string;
}

export interface ShopSubscription {
	id: number;
	user_id: string;
	shop_id: number;
	created_at: string;
	updated_at: string;
}

// View: user_all_subscriptions
export interface UserSubscription {
	subscription_type: SubscriptionType;
	target_id: number;
	target_name: string;
	subscribed_at: string;
}

// ==================== Notifications ====================

export interface NotificationLog {
	id: number;
	user_id: string;
	subscription_type: SubscriptionType;
	target_id: number;
	product_id: number;
	notification_type: NotificationType;
	title: string;
	message: string;
	is_read: boolean;
	created_at: string;
}

export interface NotificationWithDetails extends NotificationLog {
	product?: ProductWithDetails;
}

// ==================== API Response Types ====================

export interface PaginatedResponse<T> {
	data: T[];
	count: number;
	page: number;
	page_size: number;
	total_pages: number;
}

export interface SubscriptionStats {
	brands: number;
	categories: number;
	products: number;
	shops: number;
	total: number;
}

// ==================== Request Types ====================

export interface CreateSubscriptionRequest {
	type: SubscriptionType;
	target_id: number;
}

export interface UpdateNotificationRequest {
	is_read?: boolean;
}

export interface ProductFilters {
	shop_id?: number;
	brand_id?: number;
	category_id?: number;
	has_discount?: boolean;
	min_discount_rate?: number;
	locale?: Locale;
}

export interface DiscountFilters {
	shop_id?: number;
	brand_id?: number;
	category_id?: number;
	min_discount_rate?: number;
	active_only?: boolean;
	locale?: Locale;
}
