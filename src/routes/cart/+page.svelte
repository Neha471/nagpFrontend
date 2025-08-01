<script lang="ts">
	import { onMount } from 'svelte';
	import type { Product } from '../+page.svelte';

	import { loadStripe } from '@stripe/stripe-js';

	const stripePromise = loadStripe("pk_test_51NVYluSDBmemYYxaMHh0aQgznZws7Bi2tN4fWlqKf8NJLzKNxTcNay4j5z007n0CAn4LPBZjPVD1HUQHnBZ9aITq00Qj7zwrHz");

	async function pay() {
		const stripe = await stripePromise;

		if (!stripe) {
			console.error('Stripe failed to load.');
			return;
		}

		const token = localStorage.getItem('token');
		if (!token) {
			error = 'You must be logged in to view your cart';
			loading = false;
			return;
		}

		const res = await fetch('http://localhost:4000/api/payment/create-checkout-session', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }
		});

		const data = await res.json();

		if (data.id) {
			stripe.redirectToCheckout({ sessionId: data.id });
		} else {
			alert('Failed to create payment session');
		}
	}

	let cartItems: Array<{ product: Product; quantity: number }> = [];
	let loading = true;
	let error = '';
	let total = 0;

	// Get user ID from token
	function getUserIdFromToken(token: string) {
		try {
			const payload = JSON.parse(atob(token.split('.')[1]));
			return payload.userId || payload.id || payload._id || payload.sub;
		} catch {
			return null;
		}
	}

	// Get cart items from the server
	async function fetchCartItems() {
		try {
			loading = true;
			const token = localStorage.getItem('token');
			if (!token) {
				error = 'You must be logged in to view your cart';
				loading = false;
				return;
			}

			const userId = getUserIdFromToken(token);
			if (!userId) {
				error = 'Could not determine user ID';
				loading = false;
				return;
			}

			const response = await fetch(`http://localhost:4000/api/cart/${userId}`, {
				headers: {
					Authorization: `Bearer ${token}`
				}
			});

			if (!response.ok) {
				throw new Error('Failed to fetch cart items');
			}

			const data = await response.json();
			cartItems = data.items || [];
			calculateTotal();
		} catch (err) {
			error = (err as Error)?.message || 'Failed to load cart items';
		} finally {
			loading = false;
		}
	}

	// Calculate total price
	function calculateTotal() {
		total = cartItems.reduce((sum, item) => {
			return sum + item.product.price * item.quantity;
		}, 0);
	}

	// Update quantity in cart
	async function updateQuantity(productId: string, delta: number) {
		try {
			const token = localStorage.getItem('token');
			if (!token) return;

			const userId = getUserIdFromToken(token);
			if (!userId) return;

			const item = cartItems.find((item) => item.product._id === productId);
			if (!item) return;

			const newQuantity = item.quantity + delta;

			if (newQuantity < 1) {
				await removeFromCart(productId);
				return;
			}

			const response = await fetch(`http://localhost:4000/api/cart/update`, {
				method: 'PUT',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${token}`
				},
				body: JSON.stringify({
					userId,
					productId,
					quantity: newQuantity
				})
			});

			if (response.ok) {
				console.log('Cart updated successfully');
				cartItems = cartItems.map((item) => {
					if (item.product._id === productId) {
						item.quantity = newQuantity;
					}
					return item;
				});
				calculateTotal();
			}
		} catch (err) {
			console.error('Error updating cart:', err);
		}
	}

	// Remove item from cart
	async function removeFromCart(productId: string) {
		try {
			const token = localStorage.getItem('token');
			if (!token) return;

			const userId = getUserIdFromToken(token);
			if (!userId) return;

			const response = await fetch(`http://localhost:4000/api/cart/remove`, {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${token}`
				},
				body: JSON.stringify({ userId, productId })
			});

			if (response.ok) {
				cartItems = cartItems.filter((item) => item.product._id !== productId);
				calculateTotal();
			}
		} catch (err) {
			console.error('Error removing from cart:', err);
		}
	}

	// Checkout function
	function proceedToCheckout() {
		// You can implement the checkout logic here

		if (!total) {
			alert('Please add items to your cart');
			return;
		}
		pay();
	}

	onMount(() => {
		fetchCartItems();
	});
</script>

<div class="cart-container">
	<div class="cart-header">
		<h1>Your Shopping Cart</h1>
	</div>

	{#if loading}
		<div style="text-align: center; padding: 2rem 0;">
			<p>Loading your cart...</p>
		</div>
	{:else if error}
		<div style="color: #d32f2f; text-align: center; padding: 2rem 0;">
			<p>{error}</p>
		</div>
	{:else if cartItems.length === 0}
		<div class="empty-cart">
			<h2>Your cart is empty</h2>
			<p>Looks like you haven't added any items to your cart yet.</p>
			<a href="/" class="continue-shopping">Continue Shopping</a>
		</div>
	{:else}
		<div class="cart-items">
			{#each cartItems as item (item.product._id || '')}
				{#if item.product._id}
					<div class="cart-item">
						{#if item.product.image}
							<img src={item.product.image} alt={item.product.name} class="item-image" />
						{:else}
							<div
								class="item-image"
								style="background: #f0f0f0; display: flex; align-items: center; justify-content: center;"
							>
								<span style="color: #999;">No Image</span>
							</div>
						{/if}

						<div class="item-details">
							<h3 class="item-name">{item.product.name}</h3>
							<p class="item-price">${item.product.price.toFixed(2)}</p>
							<div class="quantity-controls">
								<button on:click={() => item.product._id && updateQuantity(item.product._id, -1)}
									>-</button
								>
								<span>{item.quantity}</span>
								<button on:click={() => item.product._id && updateQuantity(item.product._id, 1)}
									>+</button
								>
								<button
									class="remove-btn"
									on:click={() => item.product._id && removeFromCart(item.product._id)}
								>
									Remove
								</button>
							</div>
						</div>

						<div style="margin-left: auto; text-align: right;">
							<div class="item-price">
								${(item.product.price * item.quantity).toFixed(2)}
							</div>
						</div>
					</div>
				{/if}
			{/each}
		</div>

		<div class="cart-summary">
			<div class="total-amount">
				Total: ${total.toFixed(2)}
			</div>
			<button class="checkout-btn" on:click={proceedToCheckout} disabled={cartItems.length === 0}>
				Proceed to Checkout
			</button>
		</div>
	{/if}
</div>

<style>
	.cart-container {
		max-width: 1000px;
		margin: 2rem auto;
		padding: 0 1rem;
	}
	.cart-header {
		text-align: center;
		margin-bottom: 2rem;
	}
	.cart-items {
		margin-bottom: 2rem;
	}
	.cart-item {
		display: flex;
		align-items: center;
		padding: 1rem;
		border: 1px solid #e0e0e0;
		border-radius: 8px;
		margin-bottom: 1rem;
		background: #fff;
	}
	.item-image {
		width: 100px;
		height: 100px;
		object-fit: cover;
		border-radius: 4px;
		margin-right: 1.5rem;
	}
	.item-details {
		flex-grow: 1;
	}
	.item-name {
		font-size: 1.1rem;
		font-weight: 600;
		margin: 0 0 0.5rem 0;
		color: #1976d2;
	}
	.item-price {
		font-weight: 600;
		color: #2e7d32;
		margin-bottom: 0.5rem;
	}
	.quantity-controls {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		margin-top: 0.5rem;
	}
	.quantity-controls button {
		/* width: 30px; */
		height: 30px;
		border: 1px solid #ddd;
		background: #f5f5f5;
		border-radius: 4px;
		cursor: pointer;
		font-size: 1rem;
	}
	.quantity-controls button:hover {
		background: #e0e0e0;
	}
	.remove-btn {
		background: #ffebee !important;
		color: #c62828;
		border: 1px solid #ffcdd2 !important;
		margin-left: 1rem;
	}
	.remove-btn:hover {
		background: #ffcdd2 !important;
	}
	.cart-summary {
		background: #f5f5f5;
		padding: 1.5rem;
		border-radius: 8px;
		text-align: right;
	}
	.total-amount {
		font-size: 1.3rem;
		font-weight: 600;
		margin: 1rem 0;
	}
	.checkout-btn {
		background: #1976d2;
		color: white;
		border: none;
		padding: 0.8rem 2rem;
		border-radius: 4px;
		font-size: 1rem;
		cursor: pointer;
		transition: background 0.2s;
	}
	.checkout-btn:hover {
		background: #1565c0;
	}
	.empty-cart {
		text-align: center;
		padding: 3rem 0;
	}
	.empty-cart p {
		font-size: 1.1rem;
		color: #666;
		margin-bottom: 1.5rem;
	}
	.continue-shopping {
		display: inline-block;
		padding: 0.6rem 1.5rem;
		background: #1976d2;
		color: white;
		text-decoration: none;
		border-radius: 4px;
		transition: background 0.2s;
	}
	.continue-shopping:hover {
		background: #1565c0;
	}
</style>
