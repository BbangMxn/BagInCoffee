/**
 * 🌐 API Client
 *
 * fetch 기반 API 클라이언트
 * - 타입 안전성
 * - 에러 핸들링
 * - 자동 JSON 파싱
 * - 요청 캐싱
 * - 재시도 로직
 */

import type { ApiResponse } from '$lib/types/common';

export type { ApiResponse };

interface CacheEntry<T> {
	data: ApiResponse<T>;
	timestamp: number;
}

interface RequestOptions extends RequestInit {
	cache?: boolean;
	cacheTTL?: number; // milliseconds
	retry?: number;
	retryDelay?: number;
}

class ApiClient {
	private baseUrl: string;
	private requestCache = new Map<string, CacheEntry<any>>();
	private pendingRequests = new Map<string, Promise<any>>();

	constructor(baseUrl = '/api') {
		this.baseUrl = baseUrl;
	}

	/**
	 * 캐시에서 데이터 가져오기
	 */
	private getFromCache<T>(key: string, ttl: number): ApiResponse<T> | null {
		const entry = this.requestCache.get(key);
		if (!entry) return null;

		const isExpired = Date.now() - entry.timestamp > ttl;
		if (isExpired) {
			this.requestCache.delete(key);
			return null;
		}

		return entry.data;
	}

	/**
	 * 캐시에 데이터 저장
	 */
	private setCache<T>(key: string, data: ApiResponse<T>): void {
		this.requestCache.set(key, {
			data,
			timestamp: Date.now(),
		});

		// 캐시 크기 제한 (최대 100개)
		if (this.requestCache.size > 100) {
			const firstKey = this.requestCache.keys().next().value;
			if (firstKey) this.requestCache.delete(firstKey);
		}
	}

	/**
	 * 요청 재시도
	 */
	private async retryRequest<T>(
		fn: () => Promise<ApiResponse<T>>,
		retries: number,
		delay: number
	): Promise<ApiResponse<T>> {
		try {
			return await fn();
		} catch (error) {
			if (retries <= 0) throw error;

			await new Promise(resolve => setTimeout(resolve, delay));
			return this.retryRequest(fn, retries - 1, delay * 2); // Exponential backoff
		}
	}

	/**
	 * 중복 요청 방지 (Request deduplication)
	 */
	private async dedupedRequest<T>(
		key: string,
		fn: () => Promise<ApiResponse<T>>
	): Promise<ApiResponse<T>> {
		// 이미 진행 중인 요청이 있으면 그것을 반환
		const pending = this.pendingRequests.get(key);
		if (pending) return pending;

		const promise = fn().finally(() => {
			this.pendingRequests.delete(key);
		});

		this.pendingRequests.set(key, promise);
		return promise;
	}

	private async request<T>(
		endpoint: string,
		options?: RequestOptions
	): Promise<ApiResponse<T>> {
		const {
			cache = false,
			cacheTTL = 60000, // 1분
			retry = 0,
			retryDelay = 1000,
			...fetchOptions
		} = options || {};

		const cacheKey = `${fetchOptions.method || 'GET'}:${endpoint}`;

		// GET 요청일 때만 캐시 확인
		if (cache && (!fetchOptions.method || fetchOptions.method === 'GET')) {
			const cached = this.getFromCache<T>(cacheKey, cacheTTL);
			if (cached) return cached;
		}

		const doRequest = async (): Promise<ApiResponse<T>> => {
			try {
				const response = await fetch(`${this.baseUrl}${endpoint}`, {
					...fetchOptions,
					headers: {
						'Content-Type': 'application/json',
						...fetchOptions?.headers
					}
				});

				const data = await response.json();

				if (!response.ok) {
					return {
						success: false,
						error: {
							message: data.message || 'An error occurred',
							code: response.status.toString()
						}
					};
				}

				// 캐시 저장
				if (cache) {
					this.setCache(cacheKey, data);
				}

				return data;
			} catch (error: any) {
				return {
					success: false,
					error: {
						message: error.message || 'Network error'
					}
				};
			}
		};

		// GET 요청일 때만 중복 제거
		const shouldDedupe = !fetchOptions.method || fetchOptions.method === 'GET';
		const requestFn = shouldDedupe
			? () => this.dedupedRequest(cacheKey, doRequest)
			: doRequest;

		// 재시도 로직
		if (retry > 0) {
			return this.retryRequest(requestFn, retry, retryDelay);
		}

		return requestFn();
	}

	/**
	 * 캐시 초기화
	 */
	clearCache(pattern?: string): void {
		if (!pattern) {
			this.requestCache.clear();
			return;
		}

		// 패턴에 맞는 캐시만 삭제
		for (const key of this.requestCache.keys()) {
			if (key.includes(pattern)) {
				this.requestCache.delete(key);
			}
		}
	}

	async get<T>(
		endpoint: string,
		params?: Record<string, any>,
		options?: { cache?: boolean; cacheTTL?: number; retry?: number }
	): Promise<ApiResponse<T>> {
		const queryString = params
			? '?' +
			  Object.entries(params)
					.filter(([_, v]) => v !== undefined && v !== null)
					.map(([k, v]) => `${k}=${encodeURIComponent(v)}`)
					.join('&')
			: '';

		return this.request<T>(`${endpoint}${queryString}`, {
			method: 'GET',
			cache: options?.cache ?? true, // GET은 기본적으로 캐싱
			cacheTTL: options?.cacheTTL,
			retry: options?.retry ?? 2, // GET은 기본 2회 재시도
		});
	}

	async post<T>(
		endpoint: string,
		body?: any,
		options?: { retry?: number }
	): Promise<ApiResponse<T>> {
		return this.request<T>(endpoint, {
			method: 'POST',
			body: body ? JSON.stringify(body) : undefined,
			retry: options?.retry ?? 1, // POST는 기본 1회 재시도
		});
	}

	async patch<T>(
		endpoint: string,
		body?: any,
		options?: { retry?: number }
	): Promise<ApiResponse<T>> {
		return this.request<T>(endpoint, {
			method: 'PATCH',
			body: body ? JSON.stringify(body) : undefined,
			retry: options?.retry ?? 1,
		});
	}

	async delete<T>(
		endpoint: string,
		options?: { retry?: number }
	): Promise<ApiResponse<T>> {
		return this.request<T>(endpoint, {
			method: 'DELETE',
			retry: options?.retry ?? 1,
		});
	}
}

// Singleton instance
export const apiClient = new ApiClient();
