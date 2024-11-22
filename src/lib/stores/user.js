import { writable } from 'svelte/store';
import { ethers } from 'ethers';
import { contract } from './contract';

function createUserStore() {
  const { subscribe, set } = writable(null);

  return {
    subscribe,
    connect: async () => {
      if (typeof window.ethereum !== 'undefined') {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send('eth_requestAccounts', []);
        const signer = provider.getSigner();
        const address = await signer.getAddress();
        const contractInstance = get(contract);
        const profile = await contractInstance.profiles(address);
        set({ address, ...profile });
      } else {
        console.error('MetaMask is not installed');
      }
    },
    disconnect: () => set(null)
  };
}

export const user = createUserStore();