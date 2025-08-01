<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';

  let product: any = null;
  let loading = true;
  let error: string | null = null;
  let quantity = 1;
  let showQuantitySelector = false;
  let isLoggedIn = true;

  // Check if user is logged in
  onMount(async () => {
    try {
      isLoggedIn = true;
      const productId = $page.params.id;
      await loadProduct(productId);
    } catch (err) {
      error = 'Failed to check authentication status';
      loading = false;
    }
  });

  async function loadProduct(id: string) {
    try {
      const response = await fetch(`http://localhost:4000/api/products/${id}`);
      if (!response.ok) {
        throw new Error('Product not found');
      }
      product = await response.json();
    } catch (err) {
      error = 'Failed to load product';
    } finally {
      loading = false;
    }
  }

  function handleAddToCartClick() {
    if (!isLoggedIn) {
      goto('/login');
      return;
    }
    
    if (!showQuantitySelector) {
      showQuantitySelector = true;
      return;
    }
    
    addToCart();
  }
  
  // Function to decode JWT token
  function getUserIdFromToken() {
    const token = localStorage.getItem('token');
    console.log('Token from localStorage:', token);
    
    if (!token) {
      console.error('No token found in localStorage');
      return null;
    }
    
    try {
      // Decode the JWT token to get user info
      const parts = token.split('.');
      if (parts.length !== 3) {
        console.error('Invalid token format');
        return null;
      }
      
      const base64Url = parts[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      const payload = JSON.parse(atob(base64));
      console.log('Decoded token payload:', payload);
      
      // Check for different possible user ID fields
      const userId = payload.userId || payload.sub || payload.id || payload.user?.id;
      console.log('Extracted userId:', userId);
      
      return userId;
    } catch (e) {
      console.error('Error decoding token:', e);
      return null;
    }
  }

  async function addToCart() {
    try {
      const userId = getUserIdFromToken();
      if (!userId) {
        alert('Please log in to add items to cart');
        goto('/login');
        return;
      }

      console.log('Sending add to cart request:', {
        userId,
        productId: product._id,
        quantity: quantity
      });
      
      const response = await fetch(`http://localhost:4000/api/cart/add`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          userId,
          productId: product._id,
          quantity: quantity
        })
      });

      if (response.ok) {
        alert('Product added to cart!');
        showQuantitySelector = false;
        quantity = 1;
      } else {
        const data = await response.json();
        alert(data.message || 'Failed to add to cart');
      }
    } catch (err) {
      console.error('Add to cart error:', err);
      alert('Error adding to cart. Please check console for details.');
      throw err;
    }
  }

  function updateQuantity(change: number) {
    const newQuantity = Math.max(0, Math.min(quantity + change, product?.availableStock || 0));
    quantity = newQuantity;
  }
  
  function handleQuantityInput(event: Event) {
    const input = event.target as HTMLInputElement;
    const value = parseInt(input.value);
    if (!isNaN(value)) {
      quantity = Math.max(0, Math.min(value, product?.availableStock || 0));
    } else {
      quantity = 0;
    }
  }
</script>

<svelte:head>
  <title>{product ? product.name : 'Loading...'}</title>
</svelte:head>

<div class="product-details">
  {#if loading}
    <div class="loading">Loading product details...</div>
  {:else if error}
    <div class="error">{error}</div>
  {:else if product}
    <div class="product-container">
      <div class="product-gallery">
        {#if product.image}
          <img 
            src={product.image} 
            alt={product.name} 
            class="main-image"
          />
        {:else}
          <div class="image-placeholder">
            <span>No Image Available</span>
          </div>
        {/if}
      </div>
      
      <div class="product-info">
        <h1>{product.name}</h1>
        <div class="price">${product.price}</div>
        
        <div class="stock-status">
          {#if product.availableStock > 0}
            <span class="in-stock">In Stock ({product.availableStock} available)</span>
          {:else}
            <span class="out-of-stock">Out of Stock</span>
          {/if}
        </div>
        
        <div class="description">
          <h3>Description</h3>
          <p>{product.description}</p>
        </div>
        
        <div class="category">
          <strong>Category:</strong> {product.category}
        </div>
        
        {#if product.availableStock > 0}
          {#if showQuantitySelector}
            <div class="quantity-selector">
              <button on:click={() => updateQuantity(-1)}>-</button>
              <span class="quantity-display">{quantity}</span>
              <button on:click={() => updateQuantity(1)}>+</button>
            </div>
            
            <div class="add-to-cart-actions">
              <button 
                class="add-to-cart confirm" 
                on:click={handleAddToCartClick}
              >
                Add {quantity} to Cart - ${(product.price * quantity).toFixed(2)}
              </button>
              <button 
                class="cancel-btn" 
                on:click={() => showQuantitySelector = false}
              >
                Cancel
              </button>
            </div>

          {:else}
            <button 
              class="add-to-cart" 
              on:click={handleAddToCartClick}
            >
              Add to Cart - $${product.price.toFixed(2)}
            </button>
          {/if}
        {:else}
          <button class="out-of-stock-btn" disabled>Out of Stock</button>
        {/if}
      </div>
    </div>
  {/if}
</div>

<style>
  .product-details {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 1rem;
  }
  
  .loading, .error {
    text-align: center;
    padding: 2rem;
    font-size: 1.2rem;
  }
  
  .product-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }
  
  .product-gallery {
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
  
  .main-image {
    width: 100%;
    height: auto;
    display: block;
  }
  
  .image-placeholder {
    width: 100%;
    aspect-ratio: 1/1;
    background: #f5f5f5;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #666;
  }
  
  .product-info {
    padding: 1rem;
  }
  
  h1 {
    font-size: 2rem;
    margin: 0 0 1rem 0;
    color: #333;
  }
  
  .price {
    font-size: 1.8rem;
    font-weight: bold;
    color: #1976d2;
    margin: 1rem 0;
  }
  
  .stock-status {
    margin: 1rem 0;
  }
  
  .in-stock {
    color: #2e7d32;
    font-weight: 500;
  }
  
  .out-of-stock {
    color: #d32f2f;
    font-weight: 500;
  }
  
  .description {
    margin: 2rem 0;
    line-height: 1.6;
  }
  
  .description h3 {
    font-size: 1.3rem;
    margin-bottom: 0.5rem;
    color: #333;
  }
  
  .category {
    color: #666;
    margin: 1rem 0;
  }
  
  .quantity-selector {
    display: flex;
    align-items: center;
    margin: 1rem 0;
  }
  
  .quantity-selector button {
    width: 36px;
    height: 36px;
    font-size: 1.2rem;
    background: #f0f0f0;
    border: 1px solid #ddd;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
  }
  
  .quantity-selector {
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 1.5rem 0;
    gap: 0.5rem;
  }

  .quantity-display {
    min-width: 40px;
    text-align: center;
    font-size: 1.2rem;
    font-weight: 500;
  }
  
  .add-to-cart-actions {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .add-to-cart {
    flex: 1;
    padding: 0.8rem 1.5rem;
    font-size: 1rem;
    font-weight: 600;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s;
    background-color: #1976d2;
    color: white;
  }
  
  .add-to-cart:hover {
    background-color: #1565c0;
  }
  
  .add-to-cart.confirm {
    background-color: #2e7d32;
  }
  
  .add-to-cart.confirm:hover {
    background-color: #1b5e20;
  }
  
  .cancel-btn {
    padding: 0.8rem 1.5rem;
    font-size: 1rem;
    font-weight: 600;
    border: 1px solid #ddd;
    border-radius: 6px;
    background: white;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .cancel-btn:hover {
    background: #f5f5f5;
  }
  
  .out-of-stock-btn {
    background-color: #e0e0e0;
    color: #9e9e9e;
    cursor: not-allowed;
  }
  
  @media (max-width: 768px) {
    .product-container {
      grid-template-columns: 1fr;
    }
    
    .product-gallery {
      margin-bottom: 1rem;
    }
  }
</style>
