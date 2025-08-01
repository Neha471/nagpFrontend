<script context="module" lang="ts">
	export type Product = {
		_id?: string;
		name: string;
		description: string;
		price: number;
		category: string;
		availableStock: number;
		image?: string;
	};
</script>

<script lang="ts">
	import { onMount } from 'svelte';
	import Card from '../components/Card.svelte';
	import Header from '../components/Header.svelte';

	let cartMessage = '';
	// Helper: decode JWT (very basic, for extracting userId)
	function getUserIdFromToken(token: string) {
		try {
			const payload = JSON.parse(atob(token.split('.')[1]));
			return payload.userId || payload.id || payload._id || payload.sub;
		} catch {
			return null;
		}
	}

	async function getCartItemsCount(userId:string, token:string){
		const response = await fetch(`http://localhost:4000/api/cart/${userId}`,{
			method: 'GET',
			headers: {
				'Content-Type': 'application/json',
				Authorization: `Bearer ${token}`
			}
		})
		const data = await response.json();
		return data.items.length;
	}
	// Track per-product cart state
	let cartQuantities: { [key: string]: number } = {};
	let showQuantitySelector: { [key: string]: boolean } = {};

	function orderNow(product: Product) {
		// Here you can implement the order now logic
		// For example, you might want to navigate to a checkout page
		// or show a confirmation dialog
		cartMessage = `Order placed for ${product.name}!`;

		// Optionally, you can clear the cart after ordering
		if (product._id) {
			const qCopy = { ...cartQuantities };
			const sCopy = { ...showQuantitySelector };
			delete qCopy[product._id];
			delete sCopy[product._id];
			cartQuantities = qCopy;
			showQuantitySelector = sCopy;
		}
	}

	async function addToCart(product: Product, quantity = 1) {
		cartMessage = '';
		const token = localStorage.getItem('token');
		if (!token) {
			cartMessage = 'You must be logged in to add to cart.';
			return;
		}
		const userId = getUserIdFromToken(token);
		if (!userId) {
			cartMessage = 'Could not determine user ID.';
			return;
		}

		if (!product._id) {
			cartMessage = 'Product ID is missing.';
			return;
		}

		try {
			const res = await fetch('http://localhost:4000/api/cart/add', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${token}`
				},
				body: JSON.stringify({ userId, productId: product._id, quantity })
			});

			const data = await res.json();
			if (res.ok) {
				cartMessage = 'Added to cart!';

				// Update the cart quantities and show quantity selector
				cartQuantities = { ...cartQuantities, [product._id]: quantity };
				showQuantitySelector = { ...showQuantitySelector, [product._id]: true };
			} else {
				const errorMessage =
					data && typeof data === 'object' && 'message' in data
						? data.message
						: 'Failed to add to cart';
				cartMessage = errorMessage;
			}
		} catch (err) {
			const errorMessage =
				typeof err === 'string'
					? err
					: err && typeof err === 'object' && 'message' in err
						? String(err.message)
						: 'An unknown error occurred';
			cartMessage = `Add to cart error: ${errorMessage}`;
		}
	}

	async function updateCartQuantity(product: Product, delta: number) {
		if (!product._id) {
			cartMessage = 'Product ID is missing.';
			return;
		}

		let qty = cartQuantities[product._id] || 1;
		if (qty === 1 && delta === -1) {
			// Remove from cart if trying to decrement from 1
			await removeFromCart(product);
			return;
		}
		qty += delta;
		if (qty < 1) qty = 1;
		if (qty > product.availableStock) {
			cartMessage = `Cannot add more than ${product.availableStock} in stock.`;
			return;
		}
		await addToCart(product, qty);
	}

	async function removeFromCart(product: Product) {
		cartMessage = '';
		if (!product._id) {
			cartMessage = 'Product ID is missing.';
			return;
		}

		const token = localStorage.getItem('token');
		if (!token) {
			cartMessage = 'You must be logged in.';
			return;
		}
		const userId = getUserIdFromToken(token);
		if (!userId) {
			cartMessage = 'Could not determine user ID.';
			return;
		}
		try {
			const res = await fetch('http://localhost:4000/api/cart/remove', {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${token}`
				},
				body: JSON.stringify({ userId, productId: product._id })
			});
			let data;
			let isJson = true;
			try {
				data = await res.json();
			} catch (jsonErr) {
				isJson = false;
				cartMessage = 'Remove from cart error: Unexpected server response (not JSON).';
			}
			if (res.ok && isJson) {
				cartMessage = 'Removed from cart.';
				const qCopy = { ...cartQuantities };
				const sCopy = { ...showQuantitySelector };
				delete qCopy[product._id];
				delete sCopy[product._id];
				cartQuantities = qCopy;
				showQuantitySelector = sCopy;
			} else if (isJson) {
				cartMessage =
					data && typeof data === 'object' && 'message' in data
						? data.message
						: 'Failed to remove from cart';
			}
		} catch (err: any) {
			cartMessage =
				'Remove from cart error: ' +
				(typeof err === 'string' ? err : err && err.message ? err.message : String(err));
		}
	}

	let products: Product[] = [];
	let loading = true;
	let error = '';
	let page = 1;
	let totalPages = 1;
	let limit = 10;
	let searchTerm = '';
	let searchLoading = false;
	let selectedCategory = '';
	let categories: string[] = ['Clothing', 'Toys', 'Sports'];
	let sortBy: 'name' | 'price-asc' | 'price-desc' = 'name';

	// --- Login state logic ---
	let isLoggedIn = false;
	function checkLogin() {
		isLoggedIn = !!localStorage.getItem('token'); // Use your token key
	}
	let cartItemCount = 0;
	onMount(() => {
		checkLogin();
		getCartItemsCount(getUserIdFromToken(localStorage.getItem('token')!), localStorage.getItem('token')!).then((count) => {
			cartItemCount = count;
		});
		window.addEventListener('storage', checkLogin);
	});

	let showModal = false;
	
	function cancelLogout() {
		showModal = false;
	}
	function requestLogout() {
		showModal = true;
	}
	function handleLogout() {
		showModal = false;
		localStorage.removeItem('token');
		isLoggedIn = false;
	}

	async function fetchProducts() {
		loading = true;
		error = '';
		cartMessage = '';
		try {
			let url = `http://localhost:4000/api/products?page=${page}&limit=${limit}`;
			if (selectedCategory) {
				url += `&category=${encodeURIComponent(selectedCategory)}`;
			}
			if (searchTerm) {
				url += `&name=${encodeURIComponent(searchTerm.trim())}`;
			}
			if (sortBy == 'name') {
				url += `&sortBy=${sortBy}&sortOrder=asc`;
			}
			if (sortBy == 'price-asc') {
				url += `&sortBy=${sortBy.split('-')[0]}&sortOrder=asc`;
			}
			if (sortBy == 'price-desc') {
				url += `&sortBy=${sortBy.split('-')[0]}&sortOrder=desc`;
			}
			const res = await fetch(url);
			const data = await res.json();
			if (res.ok) {
				products = data.products || [];
				totalPages = Math.ceil((data.total || 1) / (data.limit || limit));
			} else {
				error = data.error || 'Failed to fetch products';
			}
		} catch (err: any) {
			error = typeof err === 'string' ? err : err && err.message ? err.message : String(err);
		} finally {
			loading = false;
		}
	}

	// Refetch products when page, category, or sort changes
	$: if (page || selectedCategory || sortBy) fetchProducts();

	function handleSearch(e: Event) {
		e.preventDefault();
		// Reset to first page when searching
		page = 1;
		fetchProducts();
	}

	function handleCategoryChange(e: Event) {
		selectedCategory = (e.target as HTMLSelectElement).value;
		page = 1; // Reset to first page when changing category
		fetchProducts();
	}

	function handleSortChange(e: Event) {
		sortBy = (e.target as HTMLSelectElement).value as 'name' | 'price-asc' | 'price-desc';
		page = 1; // Reset to first page when changing sort
		fetchProducts();
	}

	function handleInputKey(e: KeyboardEvent) {
		if (e.key === 'Enter') {
			handleSearch(e);
		}
	}

	
</script>

{#if showModal}
	<div class="fixed inset-0 bg-transparent backdrop-blur-sm bg-opacity-40 flex items-center justify-center z-50">
		<div class="bg-white rounded-xl shadow-lg p-6 w-full max-w-sm">
			<h2 class="text-xl font-semibold mb-4">Confirm Logout</h2>
			<p class="mb-6 text-gray-600">Are you sure you want to logout?</p>
			<div class="flex justify-between gap-3">
				<button
					on:click={cancelLogout}
					class="px-4 py-2 w-full rounded bg-gray-200 hover:bg-gray-300 transition"
				>
					Cancel
				</button>
				<button
					on:click={handleLogout}
					class="px-4 py-2 w-full rounded bg-red-500 text-white hover:bg-red-600 transition"
				>
					Logout
				</button>
			</div>
		</div>
	</div>
{/if}
<div class="container">
	<Header {cartItemCount} {isLoggedIn} {requestLogout} />
	<div class="flex flex-col sm:flex-row justify-between items-center">
		<form class="flex flex-col sm:flex-row gap-2" on:submit|preventDefault={handleSearch}>
			<select
				bind:value={selectedCategory}
				on:change={handleCategoryChange}
				style="padding:0.5rem 1rem;font-size:1rem;border-radius:5px;border:1px solid #ccc;margin-right:0.5rem;"
			>
				<option value="">All Categories</option>
				{#each categories as category}
					<option value={category}>{category}</option>
				{/each}
			</select>
			<input
				type="text"
				placeholder="Search by Product Name"
				bind:value={searchTerm}
				on:keydown={handleInputKey}
				style="padding:0.5rem 1rem;font-size:1rem;width:220px;border-radius:5px;border:1px solid #ccc;"
			/>
			<button
				type="submit"
				style="padding:0.5rem 1.2rem;border-radius:5px;border:1px solid #1976d2;background:#1976d2;color:#fff;cursor:pointer;transition:background 0.2s;"
			>
				{searchLoading ? 'Searching...' : 'Search'}
			</button>
			{#if searchTerm}
				<button
					type="button"
					on:click={() => {
						searchTerm = '';
						fetchProducts();
					}}
					style="padding:0.5rem 1rem;border-radius:5px;border:1px solid #888;background:#fff;color:#222;cursor:pointer;margin-left:0.5rem;"
					>Clear</button
				>
			{/if}
		</form>
		<div class="filters-container">
			<div class="sort-filter">
				<label for="sort">Sort by:</label>
				<select id="sort" bind:value={sortBy} on:change={handleSortChange}>
					<option value="name">Name (A-Z)</option>
					<option value="price-asc">Price (Low to High)</option>
					<option value="price-desc">Price (High to Low)</option>
				</select>
			</div>
		</div>
	</div>

	{#if loading || searchLoading}
		<div class="product-list">
			{#each new Array(10).fill(null) as product}
				<div class="product-card-skeleton">
					<div class="product-image-skeleton"></div>
					<div class="product-info-skeleton">
						<div style="width:100%;height:20px;min-height:20px;margin-bottom:0.5rem;background-color:rgb(239,235,235);border-radius:5px;"></div>
						<div style="width:100%;height:20px;min-height:20px;margin-bottom:0.5rem;background-color:rgb(239,235,235);border-radius:5px;"></div>
						<div style="width:100%;height:20px;min-height:20px;margin-bottom:0.5rem;background-color:rgb(239,235,235);border-radius:5px;"></div>
						<div style="width:100%;height:20px;min-height:40px;margin-bottom:0.5rem;background-color:rgb(239,235,235);border-radius:5px;"></div>
					</div>
				</div>
			{/each}
		</div>
	{:else if error}
		<div style="color: red;">{error}</div>
	{:else if products.length === 0}
		<div>No products found.</div>
	{:else}
		<div class="product-list">
			{#each products as product}
				<Card
					{product}
					{isLoggedIn}
					{showQuantitySelector}
					{cartQuantities}
					{addToCart}
					{removeFromCart}
					{updateCartQuantity}
					onOrderNow={orderNow}
				/>
			{/each}
		</div>
	{/if}
	{#if isLoggedIn && cartMessage}
		<div style="text-align:center;margin:1rem 0;color:#1976d2;font-weight:bold;">{cartMessage}</div>
	{/if}
	<!-- PAGINATION CONTROLS GO HERE -->
	{#if totalPages > 1}
		<div class="pagination">
			<button on:click={() => (page = page - 1)} disabled={page === 1}>Prev</button>
			<span>Page {page} of {totalPages}</span>
			<button on:click={() => (page = page + 1)} disabled={page === totalPages}>Next</button>
		</div>
	{/if}
</div>

<style>
	@import '../app.css';

	.container {
		padding: 1rem;
		margin-top: 80px;
	}
	.filters-container {
		display: flex;
		justify-content: flex-end;
	}

	.sort-filter {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.sort-filter select {
		padding: 0.5rem;
		border-radius: 4px;
		border: 1px solid #ccc;
		background-color: white;
	}

	nav {
		display: flex;
		justify-content: flex-end;
		align-items: center;
		padding: 1rem;
		background: #f5f5f5;
		border-bottom: 1px solid #ddd;
		margin-bottom: 2rem;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
	}
	nav button {
		margin-left: 1rem;
		padding: 0.5rem 1.2rem;
		border-radius: 5px;
		border: 1px solid #888;
		background: #fff;
		cursor: pointer;
		transition: background 0.2s;
	}
	nav button:hover {
		background: #e0e0e0;
	}
	.center-heading {
		display: flex;
		justify-content: center;
		align-items: center;
		margin-bottom: 2rem;
		font-size: 2.2rem;
		font-weight: bold;
		color: #222;
		min-height: 60px;
	}
	.product-list {
		width: 100%;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
		gap: 1.5rem;
		margin: 2rem 0;
	}
	.pagination {
		display: flex;
		justify-content: center;
		align-items: center;
		gap: 1rem;
		margin: 1.5rem 0;
	}
	.pagination button {
		padding: 0.4rem 1rem;
		border-radius: 5px;
		border: 1px solid #888;
		background: #fff;
		cursor: pointer;
		font-size: 1rem;
		transition: background 0.2s;
	}
	.pagination button:disabled {
		background: #eee;
		color: #aaa;
		cursor: not-allowed;
	}
	select {
		padding: 0.5rem;
		border-radius: 4px;
		border: 1px solid #ccc;
		background-color: white;
		cursor: pointer;
	}

	select:focus {
		outline: none;
		border-color: #1976d2;
		box-shadow: 0 0 0 2px rgba(25, 118, 210, 0.2);
	}

	.product-card-skeleton {
		max-width: 340px;
		width: 100%;
		background: #fff;
		border-radius: 14px;
		box-shadow: 0 2px 16px rgba(44, 62, 80, 0.1);
		border: 1px solid #e0e0e0;
		margin: 1rem auto;
		padding: 1.5rem 1.25rem 1.25rem 1.25rem;
		display: flex;
		flex-direction: column;
		min-height: 50%;
		align-items: flex-start;
		transition:
			box-shadow 0.2s,
			transform 0.2s;
		height: 100%;
		min-height: 380px;
	}
	.product-image-skeleton {
		width: 100%;
		height: 200px;
		object-fit: cover;
		border-radius: 12px;
		margin-bottom: 1rem;
		background-color: #f5f5f5;
	}
	.product-info-skeleton {
		position: relative;
		width: 100%;
		height: 20px;
		display: flex;
		flex-direction: column;
		border-radius: 4px;
		gap: 0.5rem;
	}
</style>
