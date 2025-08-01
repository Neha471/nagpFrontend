<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';

	let orderId = $page.url.searchParams.get('orderId');
	let paymentId = $page.url.searchParams.get('paymentId');

	
	const updatePaymentSuccessStatus = async (token: string) => {
		try {
			const res = await fetch('http://localhost:4000/api/payment/update-payment-status', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
				body: JSON.stringify({
					paymentId,
					status: 'PAID'
				})
			});
			const data = await res.json();
			console.log('✅ Payment updated:', data);
			if (!res.ok) throw new Error(data.message);
		} catch (err) {
			if (err instanceof Error) {
				console.error('❌ Payment update failed:', err.message);
			}
		}
	};

	const updateSuccessStatusofOrder = async (token: string) => {
		try {
			const res = await fetch('http://localhost:4000/api/orders/update-order-status', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
				body: JSON.stringify({
					orderId,
					status: 'CONFIRMED'
				})
			});
			const data = await res.json();
			console.log('✅ Order updated:', data);
			if (!res.ok) throw new Error(data.message);
		} catch (err) {
			if (err instanceof Error) {
				console.error('❌ Order update failed:', err.message);
			}
		}
	};

	onMount(() => {
		const token = localStorage.getItem('token');
		if (!token) {
			goto('/');
		}
		updateSuccessStatusofOrder(token?.toString() || '');
		updatePaymentSuccessStatus(token?.toString() || '');
	});
</script>

<style>
	main {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100vh;
		text-align: center;
		background: #f8f9fa;
		font-family: 'Nunito', sans-serif;
	}

	.success-box {
		background-color: white;
		padding: 2rem;
		border-radius: 1rem;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
		max-width: 400px;
		width: 100%;
	}

	img {
		width: 60px;
		margin-bottom: 1rem;
	}

	h1 {
		color: #28a745;
		margin-bottom: 0.5rem;
	}

	p {
		color: #333;
		font-size: 1rem;
		margin: 0.25rem 0;
	}
</style>

<main>
	<div class="success-box">
		<img src="/check-mark-button-svgrepo-com.svg" alt="Success" />
		<h1>Payment Successful!</h1>
		<p><strong>Hey, User!</strong></p>
		<p>Your order has been confirmed with <br> Order id: <span style="font-weight: bold;background-color: #28a745;color: white;padding: 2px 5px;border-radius: 5px;">{orderId}</span></p>
		<p>Thank you for your purchase 🎉</p>
		<button on:click={() => goto('/')} class="transparent border-0 duration-300 ease-in-out hover:bg-green-600 bg-green-500 text-white px-4 py-2 rounded">Continue Shopping</button>
	</div>
</main>
