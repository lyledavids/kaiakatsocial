<script>
    import '../app.css';
    import Header from '$lib/components/Header.svelte';
    
    import { contract } from '$lib/stores/contract';

    export function load() {
        contract.init();
    }
  
  </script>
  
  <Header />
  
  <main class="container mx-auto px-4 py-8">
    <slot />
  </main>