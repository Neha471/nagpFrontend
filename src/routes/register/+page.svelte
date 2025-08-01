<script>
    import { goto } from '$app/navigation';
    let email = '';
    let password = '';
    let passwordVisible = false;
    let message = '';
  
    const REGISTER_URL = 'http://localhost:4000/api/auth/register';
  
    async function handleRegister() {
      message = '';
      try {
        const res = await fetch(REGISTER_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password })
        });
        const data = await res.json();
        if (res.ok) {
        message = 'Registration successful!';
        // Redirect to login page
        goto('/login');
      } else if (
        data && (
          data.message === 'User already exists' ||
          data.message === 'user already exists' ||
          data.msg === 'User already exists' ||
          data.msg === 'user already exists'
        )
      ) {
        message = 'User already exist';
        setTimeout(() => goto('/login'), 1500);
      } else {
        message = data.message || 'Registration failed';
      }
      } catch (err) {
        message = 'Register error: ' + (typeof err === 'string' ? err : (err && err.message ? err.message : String(err)));

      }
    }
  </script>
  <style>
    .form-card {
    max-width: 350px;
    margin: 2rem auto;
    padding: 2rem 2rem 1.5rem 2rem;
    border: 1px solid #d2d2d2;
    border-radius: 12px;
    background: #fff;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    display: flex;
    flex-direction: column;
    gap: 1.1rem;
  }
  .form-card input[type="email"],
  .form-card input[type="password"],
  .form-card input[type="text"] {
    width: 100%;
    padding: 0.7rem;
    border: 1px solid #bdbdbd;
    border-radius: 6px;
    font-size: 1rem;
    margin-bottom: 0.5rem;
    background: #fafafa;
    transition: border 0.2s;
  }
  .form-card input:focus {
    border-color: #1976d2;
    outline: none;
  }
  .form-card label {
    display: flex;
    align-items: center;
    font-size: 0.98rem;
    color: #444;
    gap: 0.4rem;
    margin-bottom: 0.5rem;
    cursor: pointer;
  }
  .form-card button[type="submit"] {
    margin-top: 0.5rem;
    padding: 0.6rem 0;
    border-radius: 6px;
    border: none;
    background: #1976d2;
    color: #fff;
    font-size: 1.08rem;
    font-weight: bold;
    cursor: pointer;
    transition: background 0.2s;
  }
  .form-card button[type="submit"]:hover {
    background: #1256a0;
  }
  .message {
    text-align: center;
    margin-top: 1.5rem;
    color: #d32f2f;
    font-size: 1.02rem;
  }
</style>
<form class="form-card" on:submit|preventDefault={handleRegister}>
    <input type="email" bind:value={email} placeholder="Email" required />
    <div>
      <input type={passwordVisible ? "text" : "password"} bind:value={password} placeholder="Password" required />
      <label>
        <input type="checkbox" bind:checked={passwordVisible} />
        Show Password
      </label>
    </div>
    <button type="submit">Register</button>
  </form>
  {#if message}
    <div class="message">{message}</div>

  {/if}