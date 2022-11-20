import { defineStore } from 'pinia';

export const useWalletStore = defineStore('wallet', {
    state: () => {
        return {
            address: '',
        };
    },
    actions: {
        //@ts-ignore
        saveWalletData(payload) {
            this.address = payload.address;
        },
        connectWallet() {
            //@ts-ignore
            window.ethereum.request({ method: 'eth_requestAccounts' })
                .then((accounts) => {
                    this.saveWalletData({ address: accounts[0] });
                })
                .catch((err) => {
                    console.log(err);
                });
        }
    },
});

export default useWalletStore;
