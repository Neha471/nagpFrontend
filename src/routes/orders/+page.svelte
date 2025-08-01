<script lang="ts">
	import { onMount } from 'svelte';

	let orders: any[] = [];
	let totalOrders = 0;
	let totalSpent = 0;
	let loading = true;

	async function getOrders() {
		loading = true;
		try {
			const res = await fetch('http://localhost:4000/api/orders/all', {
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${localStorage.getItem('token')}`
				},
				method: 'GET'
			});
			const data = await res.json();
			return data.orders;
		} catch (error) {
			console.log('🚀 ~ getOrders ~ error:', error);
		} finally {
			loading = false;
		}
	}

	onMount(() => {
		getOrders().then((data) => {
			orders = data;
			totalOrders = orders.length;
			totalSpent = orders.reduce((sum, order) => order.total + sum, 0).toFixed(2);
		});
	});
</script>

<div class="order-container">
	<h1 class="heading">Your Orders</h1>

	{#if orders.length === 0}
		<p>No orders found</p>
	{/if}

	{#if loading}
		<p>Loading orders...</p>
	{/if}

	{#if orders.length > 0}
		<div class="summary">
			<div>
				<label for="totalOrders">Total Orders</label>
				<p id="totalOrders">{totalOrders}</p>
			</div>
			<div>
				<label for="totalSpent">Total Spent</label>
				<p id="totalSpent">
					$
					{totalSpent}
				</p>
			</div>
		</div>

		<div class="order-list">
			{#each orders as order}
				<div class="order-card">
					<div class="order-header">
						<div>
							<h3>Order #{order._id}</h3>
							<p>{new Date(order?.createdAt).toDateString()}</p>
						</div>
						<div class="status {order?.status.toLowerCase()}">{order?.status}</div>
					</div>

					<div class="item-list">
						{#each order.items as item}
							<div class="item-row">
								<img src={item?.product?.image} alt="Product" class="item-img" />
								<div class="item-info">
									<p>{item?.product?.name} ({item?.quantity})</p>
									<span>${item?.product?.price?.toFixed(2) * item?.quantity}</span>
								</div>
							</div>
						{/each}
					</div>

					<div class="order-footer">
						<div>
							<b>Total:</b> $
							{order?.total.toFixed(2)}
						</div>
						<button class="btn">View Details</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.order-container {
		max-width: 800px;
		margin: 2rem auto;
		background: white;
		padding: 2rem;
		border-radius: 16px;
		box-shadow: 0 8px 30px rgba(0, 0, 0, 0.05);
		font-family: 'Segoe UI', sans-serif;
	}

	.heading {
		font-size: 1.5rem;
		margin-bottom: 1.5rem;
	}

	.summary {
		display: flex;
		justify-content: space-between;
		margin-bottom: 2rem;
		padding: 1rem;
		background: #f3f4f6;
		border-radius: 10px;
	}

	.summary label {
		font-size: 0.8rem;
		color: #666;
	}

	.summary p {
		margin: 0.3rem 0 0;
		font-weight: bold;
		font-size: 1.2rem;
	}

	.order-list {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.order-card {
		background: #f9fafb;
		padding: 1rem 1.5rem;
		border-radius: 12px;
	}

	.order-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1rem;
	}

	.status {
		padding: 0.3rem 0.6rem;
		border-radius: 6px;
		font-size: 0.75rem;
		text-transform: uppercase;
	}

	.status.confirmed {
		color: #065f46;
		background: #d1fae5;
	}

	.status.pending {
		color: #92400e;
		background: #fef3c7;
	}

	.item-list {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.item-row {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.item-img {
		width: 60px;
		height: 60px;
		object-fit: cover;
		border-radius: 8px;
	}

	.item-info {
		flex: 1;
		display: flex;
		justify-content: space-between;
		font-size: 0.95rem;
	}

	.order-footer {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-top: 1rem;
		padding-top: 1rem;
		border-top: 1px solid #ddd;
	}

	.btn {
		padding: 0.5rem 1rem;
		background: #2563eb;
		color: white;
		border: none;
		border-radius: 6px;
		cursor: pointer;
		font-size: 0.85rem;
	}
</style>
