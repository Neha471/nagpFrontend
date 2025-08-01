<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import type {Product} from '../routes/+page.svelte'
  export let product: Product;

  export let isLoggedIn = false;
  export let showQuantitySelector: { [key: string]: boolean } = {};
  export let cartQuantities: { [key: string]: number } = {};
  export let addToCart: (product: Product) => void | Promise<void> = () => {};
  export let removeFromCart: (product: Product) => void | Promise<void> = () => {};
  export let updateCartQuantity: (product: Product, quantity: number) => void | Promise<void> = () => {};
  export let onOrderNow: (product: Product) => void = () => {};
  
  function navigateToProduct() {
    goto(`/products/${product._id}`);
  }

  
</script>

<style>
  .product-card {
    max-width: 340px;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 16px rgba(44, 62, 80, 0.10);
    border: 1px solid #e0e0e0;
    margin: 1rem auto;
    padding: 1.5rem 1.25rem 1.25rem 1.25rem;
    display: flex;
    flex-direction: column;
    min-height: 50%;
    align-items: flex-start;
    transition: box-shadow 0.2s, transform 0.2s;
    position: relative;
  }
  
  .card-content {
    flex: 1;
    width: 100%;
  }
  .product-image {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: 12px;
    margin-bottom: 1rem;
  }
  .product-card:hover {
    box-shadow: 0 8px 24px rgba(44, 62, 80, 0.18);
    transform: translateY(-4px) scale(1.02);
  }
  .clickable {
    cursor: pointer;
    width: 100%;
  }
  
  .product-card h3 {
    margin: 0.5rem 0;
    font-size: 1.3rem;
    color: #1976d2;
    font-weight: 700;
    transition: color 0.2s;
  }
  
  .clickable:hover h3 {
    color: #125ea6;
    text-decoration: underline;
  }
  .product-card p {
    margin: 0.25rem 0;
    color: #444;
    font-size: 1rem;
  }
  .product-card strong {
    color: #222;
  }
  .product-card .card-footer {
    width: 100%;
    margin-top: 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .add-to-cart {
    width: 100%;
  }
  .product-card button {
    background: #1976d2;
    color: #fff;
    border: none;
    border-radius: 6px;
    padding: 0.6rem;
    font-size: 1rem;
    cursor: pointer;
    transition: background 0.2s;
    margin-left: 0;
  }
  .product-card button:not(.order-now):hover {
    background: #125ea6;
  }
  .order-now:hover {
    background: #3d8b40 !important;
  }
  .product-card .quantity-controls {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
  .product-card .quantity-controls button {
    padding: 0.3rem 0.8rem;
    font-size: 1.1rem;
  }
</style>
<div class="product-card">
  <div class="card-content">
    <div 
      class="clickable" 
      on:click={navigateToProduct}
      role="button"
      tabindex="0"
      on:keydown={(e) => e.key === 'Enter' && navigateToProduct()}
    >
      {#if product.image}
        <img 
          class="product-image" 
          src={product.image} 
          alt={product.name}
        />
      {:else}
        <img 
          class="product-image" 
          src="https://placehold.co/600x700" 
          alt={product.name}
        />
      {/if}
      <h3 class="product-title">{product.name}</h3>
    </div>
    <p>{product.description}</p>
    <p><strong>Price:</strong> ${product.price}</p>
    <p><strong>Category:</strong> {product.category}</p>
    <p><strong>Stock:</strong> {product.availableStock}</p>
  </div>
  {#if isLoggedIn}
    {#if product._id && showQuantitySelector[product._id]}
      <div style="display:flex;flex-direction:column;gap:0.5rem;margin-top:0.5rem;width:100%;">
        <div style="display:flex;align-items:center;gap:0.5rem;">
          <button on:click={() => updateCartQuantity(product, -1)}>-</button>
          <span>{cartQuantities[product._id] || 1}</span>
          <button on:click={() => updateCartQuantity(product, 1)}>+</button>
          <button on:click={() => removeFromCart(product)} style="margin-left:auto;">Remove</button>
        </div>
        <button 
          class="order-now" 
          on:click={() => onOrderNow(product)}
          style="width:100%;background:#4CAF50;"
        >
          Order Now
        </button>
      </div>

    {:else}
      <button 
        class="add-to-cart" 
        on:click={() => addToCart(product)} 
        style="margin-top: 0.5rem;"
      >
        Add to Cart
      </button>
    {/if}
  {/if}
</div>
