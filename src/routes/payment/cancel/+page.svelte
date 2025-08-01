<script>
    import { page } from '$app/stores';
    let orderId = $page.url.searchParams.get('orderId');
    let paymentId = $page.url.searchParams.get('paymentId');
</script>

<main>
    You order could not be processed.
    <p>Order ID: {orderId}</p>
    <p>Payment ID: {paymentId}</p>
</main>