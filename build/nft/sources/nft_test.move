module nft::nftcard {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;
    use std::string;

    // friend nft::nft_test;
    struct NFT has key, store {
        id: UID,
        name: string::String,
        link: url::Url,
        image_url: url::Url,
        description: string::String,
        creator: string::String,
    }


    public(friend) fun mint(_name: vector<u8>, _link: vector<u8>, _image_url: vector<u8>, _description: vector<u8>, _creator: vector<u8>, ctx: &mut TxContext) : NFT {
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(_name),
            link: url::new_unsafe_from_bytes(_link),
            image_url: url::new_unsafe_from_bytes(_image_url),
            description: string::utf8(_description),
            creator: string::utf8(_creator),
        };
        nft
    }
    
    #[test_only]
    public fun mint_for_test(_name: vector<u8>, _link: vector<u8>, _image_url: vector<u8>, _description: vector<u8>, _creator: vector<u8>, ctx: &mut TxContext) : NFT {
        mint(_name, _link, _image_url, _description, _creator,ctx)
    }


    public fun update_name(nft: &mut NFT, _name: vector<u8>) {
        nft.name = string::utf8(_name);
    }

    public fun get_name(nft: &NFT) : &string::String {
        &nft.name
    }

    public fun update_link(nft: &mut NFT, _link: vector<u8>) {
        nft.link = url::new_unsafe_from_bytes(_link);

    }

    public fun update_image(nft: &mut NFT, _image: vector<u8>) {
        nft.image_url = url::new_unsafe_from_bytes(_image);
    }

    public fun update_creator(nft: &mut NFT, _creator: vector<u8>) {
        nft.creator = string::utf8(_creator);
    }


    public fun get_link(nft: &NFT) : &url::Url {
        &nft.link
    }

    public fun get_image(nft: &NFT) : &url::Url {
        &nft.image_url
    }

    public fun get_creator(nft: &NFT): &string::String {
        &nft.creator
    }


}

#[test_only]
module nft::nft_test {
    use nft::nftcard::{Self, NFT };
    use sui::test_scenario as ts;
    use sui::transfer;
    use std::string;
    use sui::url;
    #[test]
    fun mint_test() {
        let addr1 = @0xA;
        let addr2 = @0xB;
        let addr3 = @0xC;
        let scenario= ts::begin(addr1);
        {
            let nft = nftcard::mint_for_test(
                b"name",
                b"link",
                b"image",
                b"description",
                b"creator",
                ts::ctx(&mut scenario)
            );
            transfer::public_transfer(nft, addr1);
        };
        ts::next_tx(&mut scenario, addr1);
        {
            let nft = ts::take_from_sender<NFT>(&mut scenario);
            transfer::public_transfer(nft, addr2);
        };
        ts::next_tx(&mut scenario, addr2);
        {
            let nft = ts::take_from_sender<NFT>(&mut scenario);
            nftcard::update_name(&mut nft, b"new_name");
            assert!(*string::bytes(nftcard::get_name(&nft)) == b"new_name", 0);

            nftcard::update_link(&mut nft, b"new_link");
            nftcard::update_image(&mut nft, b"new_image");
            nftcard::update_creator(&mut nft, b"new_creator");
            assert!(*string::bytes(nftcard::get_creator(&nft)) == b"new_creator", 0);
            ts::return_to_sender(&mut scenario, nft);
                
        };
        ts::end(scenario);
    }

}
