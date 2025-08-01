<script>
	export let cartItemCount = 0;
	export let isLoggedIn = false;
	export let requestLogout = () => {};
	let isMobileMenuOpen = false;
</script>

<nav class="bg-white shadow-md w-full z-50 fixed top-0 left-0 right-20">
	<div class="px-4 sm:px-6 lg:px-8">
		<div class="flex justify-between h-16">
			<div class="flex items-center gap-8">
				<a href="/" class="text-2xl font-bold text-pink-600">ShopEasy</a>
				<div class="flex items-center gap-4">
					<a href="/orders" class="text-gray-600 hover:text-pink-600">Orders</a>
					<a href="/shop" class="text-gray-600 hover:text-pink-600">Shop</a>
					<a href="/contact" class="text-gray-600 hover:text-pink-600">Contact</a>
				</div>
			</div>

			<div class="hidden md:flex space-x-6 items-center">
				<div class="relative">
					<a href="/cart" class="text-gray-600 hover:text-pink-600">
						🛒
						{#if cartItemCount > 0}
							<span
								class="absolute -top-2 -right-2 bg-pink-600 text-white text-xs w-5 h-5 flex items-center justify-center rounded-full"
								>{cartItemCount}</span
							>
						{/if}
					</a>
				</div>
				{#if isLoggedIn}
					<a href="/profile" class="text-gray-600 hover:text-pink-600">Profile</a>
					<button class="text-gray-600 bg-transparent border-0 hover:text-pink-600 text-[15px] cursor-pointer" on:click={requestLogout}>Logout</button>
				{:else}
					<a class="text-gray-600 hover:text-pink-600" href="/login">Login</a>
					<a class="text-gray-600 hover:text-pink-600" href="/register">Register</a>
				{/if}
			</div>

			<div class="md:hidden absolute top-4 right-4 flex items-center">
				<button
					on:click={() => (isMobileMenuOpen = !isMobileMenuOpen)}
					class="text-gray-600 hover:text-pink-600 focus:outline-none"
				>
					{#if isMobileMenuOpen}
						✖️
					{:else}
						☰
					{/if}
				</button>
			</div>
		</div>
	</div>

	{#if isMobileMenuOpen}
		<div class="md:hidden bg-white px-4 pt-2 pb-4 shadow">
			<a href="/" class="block py-2 text-gray-600 hover:text-pink-600">Home</a>
			<a href="/shop" class="block py-2 text-gray-600 hover:text-pink-600">Shop</a>
			<a href="/orders" class="block py-2 text-gray-600 hover:text-pink-600">Orders</a>
			<a href="/contact" class="block py-2 text-gray-600 hover:text-pink-600">Contact</a>
			<a href="/cart" class="block py-2 text-gray-600 hover:text-pink-600">Cart ({cartItemCount})</a
			>
		</div>
	{/if}
</nav>

<style>
	nav a {
		transition: color 0.3s ease;
		text-decoration: none;
	}
</style>
