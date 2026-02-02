import type { Entity, Engageable, Viewable, UserGenerated } from './common';

/**
 * 커피 관련 컨텐츠 타입
 */

// ==================================================================================
// Guide Category
// ==================================================================================

/**
 * 커피 가이드 카테고리
 */
export type GuideCategory =
	| 'brewing' // 추출
	| 'beans' // 원두
	| 'equipment' // 장비
	| 'latte-art' // 라떼 아트
	| 'roasting' // 로스팅
	| 'other'; // 기타

/**
 * 가이드 난이도
 */
export type GuideDifficulty = 'beginner' | 'intermediate' | 'advanced' | 'master';

// ==================================================================================
// Base Content Interface
// ==================================================================================

/**
 * 컨텐츠 기본 인터페이스
 */
export interface BaseContent extends Entity, UserGenerated {
	/** 제목 */
	title: string;

	/** 내용 */
	content: string;

	/** 썸네일 이미지 URL */
	thumbnail_url?: string;
}

// ==================================================================================
// News Article
// ==================================================================================

/**
 * 커피 뉴스/아티클
 * @table news_articles
 */
export interface NewsArticle extends BaseContent, Engageable, Viewable {
	/** 태그 배열 */
	tags: string[];
}

// ==================================================================================
// Coffee Guide
// ==================================================================================

/**
 * 커피 가이드/튜토리얼
 * @table coffee_guides
 */
export interface CoffeeGuide extends BaseContent, Viewable {
	/** 카테고리 */
	category: GuideCategory;

	/** 난이도 */
	difficulty: GuideDifficulty;

	/** 예상 소요 시간 (분 단위) */
	estimated_time: number;
}
