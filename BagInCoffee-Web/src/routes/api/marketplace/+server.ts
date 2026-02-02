import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { MarketplaceRepository } from '$lib/server/database/Repository/marketplace.repository';

/**
 * GET /api/marketplace
 * 중고거래 아이템 목록 조회
 * Query params: page, page_size, status, condition, min_price, max_price, search
 */
export const GET: RequestHandler = async ({ url, locals: { supabase } }) => {
	const page = parseInt(url.searchParams.get('page') || '1');
	const pageSize = parseInt(url.searchParams.get('page_size') || '20');
	const status = url.searchParams.get('status') as 'active' | 'reserved' | 'sold' | null;
	const condition = url.searchParams.get('condition') || undefined;
	const minPrice = url.searchParams.get('min_price');
	const maxPrice = url.searchParams.get('max_price');
	const search = url.searchParams.get('search');

	const marketplaceRepo = new MarketplaceRepository(supabase);

	try {
		let result;

		if (search) {
			// 검색
			result = await marketplaceRepo.search(search, page, pageSize);
		} else {
			// 필터링
			const filters: any = {};
			if (status) filters.status = status;
			if (condition) filters.condition = condition;
			if (minPrice) filters.min_price = parseFloat(minPrice);
			if (maxPrice) filters.max_price = parseFloat(maxPrice);

			result = await marketplaceRepo.findAll(page, pageSize, filters);
		}

		return json({
			success: true,
			data: result.items,
			pagination: {
				page,
				page_size: pageSize,
				total_count: result.count,
				total_pages: Math.ceil(result.count / pageSize)
			}
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * POST /api/marketplace
 * 중고거래 아이템 등록
 */
export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const sellerId = user.id;
	const body = await request.json();

	// 유효성 검사
	if (!body.title || body.title.trim().length === 0) {
		return svelteError(400, 'Title is required');
	}

	if (!body.price || body.price <= 0) {
		return svelteError(400, 'Valid price is required');
	}

	if (!body.condition) {
		return svelteError(400, 'Condition is required');
	}

	const marketplaceRepo = new MarketplaceRepository(supabase);

	try {
		const item = await marketplaceRepo.create(sellerId, body);

		return json({
			success: true,
			data: item
		}, { status: 201 });
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
