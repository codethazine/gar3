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
    },
});

export default useWalletStore;
