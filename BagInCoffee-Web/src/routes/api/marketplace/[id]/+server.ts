import { json, error as svelteError } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { MarketplaceRepository } from '$lib/server/database/Repository/marketplace.repository';

/**
 * GET /api/marketplace/[id]
 * 특정 아이템 조회
 */
export const GET: RequestHandler = async ({ params, locals: { supabase } }) => {
	const marketplaceRepo = new MarketplaceRepository(supabase);

	try {
		const item = await marketplaceRepo.findById(params.id);

		if (!item) {
			return svelteError(404, 'Item not found');
		}

		return json({
			success: true,
			data: item
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};

/**
 * PATCH /api/marketplace/[id]
 * 아이템 수정
 */
export const PATCH: RequestHandler = async ({ params, request, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const sellerId = user.id;
	const body = await request.json();

	const marketplaceRepo = new MarketplaceRepository(supabase);

	try {
		const item = await marketplaceRepo.update(params.id, sellerId, body);

		return json({
			success: true,
			data: item
		});
	} catch (err: any) {
		return svelteError(403, 'Forbidden or not found');
	}
};

/**
 * DELETE /api/marketplace/[id]
 * 아이템 삭제
 */
export const DELETE: RequestHandler = async ({ params, locals: { supabase } }) => {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return svelteError(401, 'Unauthorized');
	}

	const sellerId = user.id;
	const marketplaceRepo = new MarketplaceRepository(supabase);

	try {
		const success = await marketplaceRepo.delete(params.id, sellerId);

		if (!success) {
			return svelteError(403, 'Forbidden or not found');
		}

		return json({
			success: true,
			message: 'Item deleted'
		});
	} catch (err: any) {
		return svelteError(500, err.message);
	}
};
