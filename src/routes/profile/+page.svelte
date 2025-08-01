<script lang="ts">
	import { onMount } from 'svelte';

	let user = {
		firstName: '',
		lastName: '',
		email: '',
		country: '',
		about: '',
		designation: '',
		username: '',
		createdAt: 'yyyy-mm-dd',
		firstPurchase: 'yyyy-mm-dd',
		avatar: 'https://i.pravatar.cc/150?img=47',
		isVerified: false,
		subscribed: false
	};

	async function getUser() {
		try {
			const res = await fetch('http://localhost:4000/api/auth/me', {
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${localStorage.getItem('token')}`
				},
				method: 'GET'
			});
			const data = await res.json();
			return data;
		} catch (error) {
			console.log('🚀 ~ getUser ~ error:', error);
		}
	}

	onMount(() => {
		getUser().then((data) => {
			user = data;
		});
	});
</script>

<div class="overlay">
	<div class="profile-modal">
		<div class="header">
			<img
				src={user?.avatar || 'https://i.pravatar.cc/150?img=47'}
				alt="User Avatar"
				class="avatar"
			/>
			<div class="info">
				<h2>
					{user?.firstName}
					{user?.lastName}
					<span class="tag">{user?.subscribed ? 'Subscribed' : 'Not Subscribed'}</span>
				</h2>
				<p class="email">{user?.email}</p>
			</div>
			<div class="actions">
				<button class="btn small">Archive</button>
				<button class="btn small primary">View orders</button>
			</div>
		</div>

		<div class="meta">
			<div>
				<label for="firstSeen">Joined ShopEasy</label>
				<p id="firstSeen">{new Date(user?.createdAt).toDateString()}</p>
			</div>
			<div>
				<label for="firstPurchase">First purchase</label>
				<p id="firstPurchase">{user?.firstPurchase || 'Not Purchased yet'}</p>
			</div>
		</div>

		<form class="form">
			<div class="field-group">
				<label for="name">Name</label>
				<div class="split">
					<input type="text" value={user?.firstName} id="firstName" />
					<input type="text" value={user?.lastName} id="lastName" />
				</div>
			</div>

			<div class="field-group">
				<label for="email">Email address</label>
				<input type="email" value={user?.email} id="email" />
				{#if user?.isVerified}
					<p class="verified">✔ Verified</p>
				{:else}
					<p class="not-verified">Not Verified</p>
				{/if}
			</div>

			<div class="field-group">
				<label for="designation">Designation</label>
				<input type="text" value={user?.designation} id="designation" />
			</div>

			<div class="field-group">
				<label for="about">About</label>
				<textarea value={user?.about} id="about"></textarea>
			</div>

			<div class="field-group">
				<label for="country">Country</label>
				<select id="country">
					<option>United States</option>
					<option>India</option>
					<option>Germany</option>
					<option>Japan</option>
				</select>
			</div>

			<div class="field-group">
				<label for="username">Username</label>
				<div class="split">
					<span>shopeasy.com/</span>
					<input type="text" value={user?.username} id="username" />
				</div>
			</div>

			<div class="form-actions">
				<button class="btn cancel">Cancel</button>
				<button class="btn save">Save changes</button>
			</div>
		</form>
	</div>
</div>

<style>
	* {
		box-sizing: border-box;
		font-family: 'Nunito', sans-serif;
	}
	.overlay {
		display: flex;
		justify-content: center;
		align-items: center;
		min-height: 100vh;
		padding: 2rem;
	}

	.profile-modal {
		background: white;
		border-radius: 18px;
		width: 100%;
		max-width: 600px;
		padding: 2rem;
	}

	.header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 1rem;
		flex-wrap: wrap;
	}

	.avatar {
		width: 70px;
		height: 70px;
		border-radius: 50%;
		object-fit: cover;
	}

	.info h2 {
		margin: 0;
		font-size: 1.3rem;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.tag {
		background: #d1fae5;
		color: #065f46;
		padding: 0.2rem 0.5rem;
		font-size: 0.8rem;
		border-radius: 6px;
	}

	.email {
		color: #666;
		font-size: 0.9rem;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
	}

	.btn {
		padding: 0.5rem 1rem;
		border: none;
		border-radius: 6px;
		cursor: pointer;
		font-weight: 500;
	}

	.small {
		font-size: 0.85rem;
	}

	.primary {
		background: #2563eb;
		color: white;
	}

	.meta {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
		gap: 1rem;
		margin: 2rem 0;
	}

	.meta label {
		color: #888;
		font-size: 0.75rem;
	}

	.meta p {
		margin: 0;
		font-weight: 500;
	}

	.form {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.field-group label {
		font-weight: 500;
		display: block;
		margin-bottom: 0.3rem;
	}

	.field-group input,
	.field-group textarea,
	.field-group select {
		width: 100%;
		padding: 0.6rem;
		border: 1px solid #ccc;
		border-radius: 6px;
	}

	.split {
		display: flex;
		gap: 0.5rem;
		align-items: center;
	}

	.split span {
		font-size: 0.9rem;
		color: #555;
	}

	.verified {
		color: #059669;
		font-size: 0.8rem;
		margin-top: 0.3rem;
	}

	.form-actions {
		display: flex;
		justify-content: flex-end;
		gap: 0.8rem;
		margin-top: 1rem;
	}

	.cancel {
		background: #e5e7eb;
	}

	.save {
		background: #3b82f6;
		color: white;
	}
	.not-verified {
		color: #dc2626;
		font-size: 0.8rem;
		margin-top: 0.3rem;
	}
</style>
