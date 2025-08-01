<script lang="ts">
	import { goto } from '$app/navigation';
	let email = '';
	let password = '';
	let showPassword = false;

	let message = '';
	const togglePassword = () => {
		showPassword = !showPassword;
	};

	const LOGIN_URL = 'http://localhost:4000/api/auth/login';

	async function handleLogin() {
		message = '';
		try {
			const res = await fetch(LOGIN_URL, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ email, password })
			});
			const data = await res.json();
			if (res.ok) {
				message = 'Login successful!';
				if (data.token) {
					localStorage.setItem('token', data.token);
				}
				goto('/');
			} else {
				message =
					data && typeof data === 'object' && 'message' in data ? data.message : 'Login failed';
			}
		} catch (err) {
			if (err instanceof Error) {
				console.error('❌ Login failed:', err.message);
				message = 'Login error: ' + (typeof err === 'string' ? err : err && err.message ? err.message : String(err));
			} else {
				console.error('❌ Login failed:', err);
				message = 'Login error: ' + (typeof err === 'string' ? err : 'Something went wrong');
			}
		}
	}
</script>

<div class="min-h-screen flex items-center justify-center px-4">
	<div class="w-full max-w-lg bg-white rounded-2xl shadow-lg p-8 border border-gray-300">
		<h2 class="text-3xl font-bold text-center text-blue-600 mb-6">Welcome to ShopEasy</h2>

		<form on:submit|preventDefault={handleLogin} class="space-y-5 w-full">
			<div class="flex flex-col w-full">
				<label for="email" class="block text-sm font-medium text-gray-700">Email</label>
				<input
					type="email"
					bind:value={email}
					required
					class="mt-1 px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
					placeholder="you@example.com"
				/>
			</div>

			<div class="flex flex-col w-full relative">
				<label for="password" class="block text-sm font-medium text-gray-700">Password</label>
				<input
					id="password"
					type={showPassword ? 'text' : 'password'}
					bind:value={password}
					required
					class="mt-1 px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
					placeholder="Password"
				/>
				<button
					type="button"
					class="absolute bg-transparent border-none right-2 top-8 text-sm text-blue-500 hover:text-blue-700"
					on:click={togglePassword}
				>
					{showPassword ? 'Hide' : 'Show'}
				</button>
			</div>

			<div class="flex items-center justify-between">
				<label class="flex items-center text-sm text-gray-600">
					<input type="checkbox" class="mr-2" /> Remember me
				</label>
				<a
					href="/forget-password"
					class="text-sm text-blue-600 hover:underline text-decoration-none">Forgot password?</a
				>
			</div>

			<button
				type="submit"
				class="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl border-0 transition text-lg font-semibold"
			>
				Sign In
			</button>
		</form>

		<p class="mt-6 text-center text-sm text-gray-600">
			Don't have an account?
			<a href="/register" class="text-blue-500 hover:underline">Sign up</a>
		</p>
	</div>
</div>
