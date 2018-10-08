pragma solidity ^0.4.21;

library BaseCardLib {
    //rarity //total:240
    //1759945318431593765795862744880641490375032787903448571566443677068820480
    //0xFF0000000000000000000000000000000000000000000000000000000000
    function toRarity(uint256 self) public pure returns(uint256) {
        return (self >>232 ) & 255; //0xFF0000000000000000000000000000000000000000000000000000000000
    }
    //00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    //6901746346790563787434755862277025452451108972170386555162524223799295
    function setRarity(uint256 self, uint256 _val) public returns(uint256) {
        return (self && 6901746346790563787434755862277025452451108972170386555162524223799295 ) 
        | (val << 232); //0xFF0000000000000000000000000000000000000000000000000000000000
    }

    //regions
    //6470387200116153550720083620884711361672914661409737395464866459811840
    //0xF000000000000000000000000000000000000000000000000000000000
    function toRegion1(uint256 self) public pure returns(uint256) {
        return (self >>228 ) & 15; //0xF000000000000000000000000000000000000000000000000000000000
    }
    //404399200007259596920005226305294460104557166338108587216554153738240
    //0xF00000000000000000000000000000000000000000000000000000000
    function toRegion2(uint256 self) public pure returns(uint256) {
        return (self >>224 ) & 15; //0xF00000000000000000000000000000000000000000000000000000000
    }
    function toRegion3(uint256 self) public pure returns(uint256) {
        return (self & 25274950000453724807500326644080903756534822896131786701034634608640) >>220; //0xF0000000000000000000000000000000000000000000000000000000
    }
    function toRegion4(uint256 self) public pure returns(uint256) {
        return (self & 1579684375028357800468770415255056484783426431008236668814664663040) >>216; //0xF000000000000000000000000000000000000000000000000000000
    }
    //98730273439272362529298150953441030298964151938014791800916541440
    //0xF00000000000000000000000000000000000000000000000000000
    function toRegion5(uint256 self) public pure returns(uint256) {
        return (self >>212 ) & 15; //0xF00000000000000000000000000000000000000000000000000000
    }
    //6170642089954522658081134434590064393685259496125924487557283840
    //0xF0000000000000000000000000000000000000000000000000000
    function toRegion6(uint256 self) public pure returns(uint256) {
        return (self >>208 ) & 15; //0xF0000000000000000000000000000000000000000000000000000
    }
    function toRegion7(uint256 self) public pure returns(uint256) {
        return (self & 385665130622157666130070902161879024605328718507870280472330240) >>204; //0xF000000000000000000000000000000000000000000000000000
    }
    function toRegion8(uint256 self) public pure returns(uint256) {
        return (self & 24104070663884854133129431385117439037833044906741892529520640) >>200; //0xF00000000000000000000000000000000000000000000000000
    }

    //passive1
    function toDebuff1(uint256 self) public pure returns(uint256) {
        return (self & 1600660942523603594778126302917954936106100638338328800788480) >>192; //0xFF000000000000000000000000000000000000000000000000
    }

    //6252581806732826542102055870773261469164455618509096878080
    //0xFF0000000000000000000000000000000000000000000000
    //passive2
    function tobuff1(uint256 self) public pure returns(uint256) {
        return (self >>184 ) & 65535; //0xFF0000000000000000000000000000000000000000000000
    }
    //24424147682550103680086155745208052613923654759801159680
    //0xFF00000000000000000000000000000000000000000000
    //passive3
    function toDebuff2(uint256 self) public pure returns(uint256) {
        return (self >>176 ) & 65535; //0xFF00000000000000000000000000000000000000000000
    }
    //passive4
    function tobuff2(uint256 self) public pure returns(uint256) {
        return (self & 95406826884961342500336545879718955523139276405473280) >>168; //0xFF000000000000000000000000000000000000000000
    }
    //372682917519380244141939632342652170012262798458880
    //0xFF0000000000000000000000000000000000000000
    //passive5
    function toDebuff3(uint256 self) public pure returns(uint256) {
        return (self >>160 ) & 65535; //0xFF0000000000000000000000000000000000000000
    }
    //passive6
    function tobuff3(uint256 self) public pure returns(uint256) {
        return (self & 1455792646560079078679451688838485039110401556480) >>152; //0xFF00000000000000000000000000000000000000
    }
    //5686690025625308901091608159525332184025006080
    //0xFF000000000000000000000000000000000000
    //passive7
    function toDebuff4(uint256 self) public pure returns(uint256) {
        return (self >> 144 ) & 65535; //0xFF000000000000000000000000000000000000
    }
    //passive8
    function tobuff4(uint256 self) public pure returns(uint256) {
        return (self & 22213632912598862894889094373145828843847680) >> 136; //0xFF0000000000000000000000000000000000
    }
    //passive9
    function toDebuff5(uint256 self) public pure returns(uint256) {
        return (self & 86772003564839308183160524895100893921280) >> 128; //0xFF00000000000000000000000000000000
    }
    //338953138925153547590470800371487866880
    //0xFF000000000000000000000000000000
    //passive10
    function tobuff5(uint256 self) public pure returns(uint256) {
        return (self >>120 ) & 65535; //0xFF000000000000000000000000000000
    }

    //features
    function toHp(uint256 self) public pure returns(uint256) {
        return (self & 1329226728134315644674405563577139200) >>100;   //0xFFFFF0000000000000000000000000
    }
    function toAp(uint256 self) public pure returns(uint256) {
        return (self & 1267649391302409786867528499200) >>80; //0xFFFFF00000000000000000000
    }
    function toDeff(uint256 self) public pure returns(uint256) {
        return (self & 1208924666693124567859200) >>60; //0xFFFFF000000000000000
    }
    //1152920405095219200
    //0xFFFFF0000000000
    function toSpeed(uint256 self) public pure returns(uint256) {
        return (self >> 40 ) & 1048575; //0xFFFFF0000000000
    }
    function toWeight(uint256 self) public pure returns(uint256) {
        return (self & 1099510579200) >>20; //0xFFFFF00000
    }
    function toLifeSpan(uint256 self) public pure returns(uint256) {
        return (self & 1048575) ; //0xFFFFF
    }
    
}

pragma solidity ^0.4.21;

contract BaseCardLibTest {
    using BaseCardLib for uint256;
    uint256[] public val;
    
    function BaseCardLibTest() public {
        val.push(1);    
        val.push(483122250857357694405257107524222366032853776359798369891734432751026236);    
    }
    //         rrRRRRRRRRb5b5b4b4b3b3b2b2b1b1HHHHHAAAAADDDDDSSSSSWWWWWLLLLL    
    //input: 0x46000010000000000000050000000002710003e80012c00050017700003c
    //val : 483122250857357694405257107524222366032853776359798369891734432751026236
    //ok.
    function addVal(uint256 _val ) public {
        val.push(_val);
    }
    //rarity //total:240
    //1759945318431593765795862744880641490375032787903448571566443677068820480
    //0xFF0000000000000000000000000000000000000000000000000000000000
    function toRarity() public view returns(uint256) {
        return val[1].toRarity();
    }

    function setRarity(uint256 _val) public {
        return val[1].setRarity(_val);
    }

    //regions
    //6470387200116153550720083620884711361672914661409737395464866459811840
    //0xF000000000000000000000000000000000000000000000000000000000
    function toRegion1() public view returns(uint256) {
        return val[1].toRegion1();
    }
    //404399200007259596920005226305294460104557166338108587216554153738240
    //0xF00000000000000000000000000000000000000000000000000000000
    function toRegion2() public view returns(uint256) {
        return val[1].toRegion2();
    }
    function toRegion3() public view returns(uint256) {
        return val[1].toRegion3();
    }
    function toRegion4() public view returns(uint256) {
        return val[1].toRegion4();
    }
    //98730273439272362529298150953441030298964151938014791800916541440
    //0xF00000000000000000000000000000000000000000000000000000
    function toRegion5() public view returns(uint256) {
        return val[1].toRegion5();
    }
    //6170642089954522658081134434590064393685259496125924487557283840
    //0xF0000000000000000000000000000000000000000000000000000
    function toRegion6() public view returns(uint256) {
        return val[1].toRegion6();
    }
    function toRegion7() public view returns(uint256) {
        return val[1].toRegion7();
    }
    function toRegion8() public view returns(uint256) {
        return val[1].toRegion8();
    }

    function toDebuff1() public view returns(uint256) {
        return val[1].toDebuff1();
    }
    //6252581806732826542102055870773261469164455618509096878080
    //0xFF0000000000000000000000000000000000000000000000
    function tobuff1() public view returns(uint256) {
        return val[1].tobuff1();
    }
    //24424147682550103680086155745208052613923654759801159680
    //0xFF00000000000000000000000000000000000000000000
    function toDebuff2() public view returns(uint256) {
        return val[1].toDebuff2();
    }
    function tobuff2() public view returns(uint256) {
        return val[1].tobuff2();
    }
    //372682917519380244141939632342652170012262798458880
    //0xFF0000000000000000000000000000000000000000
    function toDebuff3() public view returns(uint256) {
        return val[1].toDebuff3();
    }
    function tobuff3() public view returns(uint256) {
        return val[1].tobuff3();
    }
    //5686690025625308901091608159525332184025006080
    //0xFF000000000000000000000000000000000000
    function toDebuff4() public view returns(uint256) {
        return val[1].toDebuff4();
    }
    function tobuff4() public view returns(uint256) {
        return val[1].tobuff4();
    }
    function toDebuff5() public view returns(uint256) {
        return val[1].toDebuff5();
    }
    //338953138925153547590470800371487866880
    //0xFF000000000000000000000000000000
    function tobuff5() public view returns(uint256) {
        return val[1].tobuff5();
    }

    //features
    function toHp() public view returns(uint256) {
        return val[1].toHp();
    }
    function toAp() public view returns(uint256) {
        return val[1].toAp();
    }
    function toDeff() public view returns(uint256) {
        return val[1].toDeff();
    }
    //1152920405095219200
    //0xFFFFF0000000000
    function toSpeed() public view returns(uint256) {
        return val[1].toSpeed();
    }
    function toWeight() public view returns(uint256) {
        return val[1].toWeight();
    }
    function toLifeSpan() public view returns(uint256) {
        return val[1].toLifeSpan();
    }
    
    function toMask(uint256 _mask ) public pure returns(uint256) {
        return _mask ;
    }
    
}


/*

pragma solidity ^0.4.21;

contract Bitwise {
    
    uint256[] public val;
    
    function Bitwise() public {
        val.push(1);    
        val.push(483122250857357694405257107524222366032853776359798369891734432751026236);    
    }
    //         rrRRRRRRRRb5b5b4b4b3b3b2b2b1b1HHHHHAAAAADDDDDSSSSSWWWWWLLLLL    
    //input: 0x46000010000000000000050000000002710003e80012c00050017700003c
    //val : 483122250857357694405257107524222366032853776359798369891734432751026236
    //ok.
    function addVal(uint256 _val ) public {
        val.push(_val);
    }
    //rarity //total:240
    function toRarityx() public view returns(uint256) {
        return (self >>232 ) & 255; //0xFF0000000000000000000000000000000000000000000000000000000000
    }
    //rarity //total:240
    function toRarity() public view returns(uint256) {
        return (self & 1759945318431593765795862744880641490375032787903448571566443677068820480) >>232; //0xFF0000000000000000000000000000000000000000000000000000000000
    }
    //regions
    function toRegion1x() public view returns(uint256) {
        return (self >>228 ) & 15; //0xFFFFF00000
    }
    function toRegion1() public view returns(uint256) {
        return (self & 6470387200116153550720083620884711361672914661409737395464866459811840) >>228; //0xF000000000000000000000000000000000000000000000000000000000
    }
    function toRegion2x() public view returns(uint256) {
        return (self >>224 ) & 15; //0xFFFFF00000
    }
    function toRegion2() public view returns(uint256) {
        return (self & 404399200007259596920005226305294460104557166338108587216554153738240) >>224; //0xF00000000000000000000000000000000000000000000000000000000
    }
    function toRegion3x() public view returns(uint256) {
        return (self >>220 ) & 15; //0xFFFFF00000
    }
    function toRegion3() public view returns(uint256) {
        return (self & 25274950000453724807500326644080903756534822896131786701034634608640) >>220; //0xF0000000000000000000000000000000000000000000000000000000
    }
    function toRegion4x() public view returns(uint256) {
        return (self >>216 ) & 15; //0xFFFFF00000
    }
    function toRegion4() public view returns(uint256) {
        return (self & 1579684375028357800468770415255056484783426431008236668814664663040) >>216; //0xF000000000000000000000000000000000000000000000000000000
    }
    function toRegion5x() public view returns(uint256) {
        return (self >>212 ) & 15; //0xFFFFF00000
    }
    function toRegion5() public view returns(uint256) {
        return (self & 98730273439272362529298150953441030298964151938014791800916541440) >>212; //0xF00000000000000000000000000000000000000000000000000000
    }
    function toRegion6x() public view returns(uint256) {
        return (self >>208 ) & 15; //0xFFFFF00000
    }
    function toRegion6() public view returns(uint256) {
        return (self & 6170642089954522658081134434590064393685259496125924487557283840) >>208; //0xF0000000000000000000000000000000000000000000000000000
    }
    function toRegion7x() public view returns(uint256) {
        return (self >>204 ) & 15; //0xFFFFF00000
    }
    function toRegion7() public view returns(uint256) {
        return (self & 385665130622157666130070902161879024605328718507870280472330240) >>204; //0xF000000000000000000000000000000000000000000000000000
    }
    function toRegion8x() public view returns(uint256) {
        return (self >>200 ) & 15; //0xFFFFF00000
    }
    function toRegion8() public view returns(uint256) {
        return (self & 24104070663884854133129431385117439037833044906741892529520640) >>200; //0xF00000000000000000000000000000000000000000000000000
    }

    function toDebuff1x() public view returns(uint256) {
        return (self >>192 ) & 65535; //0xFFFFF00000
    }
    function toDebuff1() public view returns(uint256) {
        return (self & 1600660942523603594778126302917954936106100638338328800788480) >>192; //0xFF000000000000000000000000000000000000000000000000
    }
    function tobuff1x() public view returns(uint256) {
        return (self >>184 ) & 65535; //0xFFFFF00000
    }
    function tobuff1() public view returns(uint256) {
        return (self & 6252581806732826542102055870773261469164455618509096878080) >>184; //0xFF0000000000000000000000000000000000000000000000
    }
    function toDebuff2x() public view returns(uint256) {
        return (self >>176 ) & 65535; //0xFFFFF00000
    }
    function toDebuff2() public view returns(uint256) {
        return (self & 24424147682550103680086155745208052613923654759801159680) >>176; //0xFF00000000000000000000000000000000000000000000
    }
    function tobuff2x() public view returns(uint256) {
        return (self >>168 ) & 65535; //0xFFFFF00000
    }
    function tobuff2() public view returns(uint256) {
        return (self & 95406826884961342500336545879718955523139276405473280) >>168; //0xFF000000000000000000000000000000000000000000
    }
    function toDebuff3x() public view returns(uint256) {
        return (self >>160 ) & 65535; //0xFFFFF00000
    }
    function toDebuff3() public view returns(uint256) {
        return (self & 372682917519380244141939632342652170012262798458880) >>160; //0xFF0000000000000000000000000000000000000000
    }
    function tobuff3x() public view returns(uint256) {
        return (self >>152 ) & 65535; //0xFFFFF00000
    }
    function tobuff3() public view returns(uint256) {
        return (self & 1455792646560079078679451688838485039110401556480) >>152; //0xFF00000000000000000000000000000000000000
    }
    function toDebuff4x() public view returns(uint256) {
        return (self >>144 ) & 65535; //0xFFFFF00000
    }
    function toDebuff4() public view returns(uint256) {
        return (self & 5686690025625308901091608159525332184025006080) >>144; //0xFF000000000000000000000000000000000000
    }
    function tobuff4x() public view returns(uint256) {
        return (self >>136 ) & 65535; //0xFFFFF00000
    }
    function tobuff4() public view returns(uint256) {
        return (self & 22213632912598862894889094373145828843847680) >>136; //0xFF0000000000000000000000000000000000
    }
    function toDebuff5x() public view returns(uint256) {
        return (self >>128 ) & 65535; //0xFFFFF00000
    }
    function toDebuff5() public view returns(uint256) {
        return (self & 86772003564839308183160524895100893921280) >>128; //0xFF00000000000000000000000000000000
    }
    function tobuff5x() public view returns(uint256) {
        return (self >>120 ) & 65535; //0xFFFFF00000
    }
    function tobuff5() public view returns(uint256) {
        return (self & 338953138925153547590470800371487866880) >>120; //0xFF000000000000000000000000000000
    }
    //features
    function toHpx() public view returns(uint256) {
        return (self >>100 ) & 1048575; //0xFFFFF00000
    }
    function toHp() public view returns(uint256) {
        return (self & 1329226728134315644674405563577139200) >>100;   //0xFFFFF0000000000000000000000000
    }
    function toApx() public view returns(uint256) {
        return (self >>80 ) & 1048575; //0xFFFFF00000
    }
    function toAp() public view returns(uint256) {
        return (self & 1267649391302409786867528499200) >>80; //0xFFFFF00000000000000000000
    }
    function toDeffx() public view returns(uint256) {
        return (self >>60 ) & 1048575; //0xFFFFF00000
    }
    function toDeff() public view returns(uint256) {
        return (self & 1208924666693124567859200) >>60; //0xFFFFF000000000000000
    }
    function toSpeedx() public view returns(uint256) {
        return (self >>40 ) & 1048575; //0xFFFFF00000
    }
    function toSpeed() public view returns(uint256) {
        return (self & 1152920405095219200) >>40; //0xFFFFF0000000000
    }
    function toWeightx() public view returns(uint256) {
        return (self >>20 ) & 1048575; //0xFFFFF00000
    }
    function toWeight() public view returns(uint256) {
        return (self & 1099510579200) >>20; //0xFFFFF00000
    }
    function toLifeSpan() public view returns(uint256) {
        return (self & 1048575) ; //0xFFFFF
    }
    
    function toMask(uint256 _mask ) public pure returns(uint256) {
        return _mask ;
    }
    
}

/*
pragma solidity ^0.4.21;

contract Bitwise {
    
    uint256[] public val;
    
    function Bitwise() public {
        val.push(1);    
        val.push(483122250857357694405257107524222366032853776359798369891734432751026236);    
    }
    //         rrRRRRRRRRb5b5b4b4b3b3b2b2b1b1HHHHHAAAAADDDDDSSSSSWWWWWLLLLL    
    //input: 0x46000010000000000000050000000002710003e80012c00050017700003c
    //val : 483122250857357694405257107524222366032853776359798369891734432751026236
    //ok.
    function addVal(uint256 _val ) public {
        val.push(_val);
    }
    //rarity //total:240
    function toRarity() public view returns(uint256) {
        return (self & 1759945318431593765795862744880641490375032787903448571566443677068820480) >>232; //0xFF0000000000000000000000000000000000000000000000000000000000
    }
    //regions
    function toRegion1() public view returns(uint256) {
        return (self & 6470387200116153550720083620884711361672914661409737395464866459811840) >>228; //0xF000000000000000000000000000000000000000000000000000000000
    }
    function toRegion2() public view returns(uint256) {
        return (self & 404399200007259596920005226305294460104557166338108587216554153738240) >>224; //0xF00000000000000000000000000000000000000000000000000000000
    }
    function toRegion3() public view returns(uint256) {
        return (self & 25274950000453724807500326644080903756534822896131786701034634608640) >>220; //0xF0000000000000000000000000000000000000000000000000000000
    }
    function toRegion4() public view returns(uint256) {
        return (self & 1579684375028357800468770415255056484783426431008236668814664663040) >>216; //0xF000000000000000000000000000000000000000000000000000000
    }
    function toRegion5() public view returns(uint256) {
        return (self & 98730273439272362529298150953441030298964151938014791800916541440) >>212; //0xF00000000000000000000000000000000000000000000000000000
    }
    function toRegion6() public view returns(uint256) {
        return (self & 6170642089954522658081134434590064393685259496125924487557283840) >>208; //0xF0000000000000000000000000000000000000000000000000000
    }
    function toRegion7() public view returns(uint256) {
        return (self & 385665130622157666130070902161879024605328718507870280472330240) >>204; //0xF000000000000000000000000000000000000000000000000000
    }
    function toRegion8() public view returns(uint256) {
        return (self & 24104070663884854133129431385117439037833044906741892529520640) >>200; //0xF00000000000000000000000000000000000000000000000000
    }

    function toDebuff1() public view returns(uint256) {
        return (self & 1600660942523603594778126302917954936106100638338328800788480) >>192; //0xFF000000000000000000000000000000000000000000000000
    }
    function tobuff1() public view returns(uint256) {
        return (self & 6252581806732826542102055870773261469164455618509096878080) >>184; //0xFF0000000000000000000000000000000000000000000000
    }
    function toDebuff2() public view returns(uint256) {
        return (self & 24424147682550103680086155745208052613923654759801159680) >>176; //0xFF00000000000000000000000000000000000000000000
    }
    function tobuff2() public view returns(uint256) {
        return (self & 95406826884961342500336545879718955523139276405473280) >>168; //0xFF000000000000000000000000000000000000000000
    }
    function toDebuff3() public view returns(uint256) {
        return (self & 372682917519380244141939632342652170012262798458880) >>160; //0xFF0000000000000000000000000000000000000000
    }
    function tobuff3() public view returns(uint256) {
        return (self & 1455792646560079078679451688838485039110401556480) >>152; //0xFF00000000000000000000000000000000000000
    }
    function toDebuff4() public view returns(uint256) {
        return (self & 5686690025625308901091608159525332184025006080) >>144; //0xFF000000000000000000000000000000000000
    }
    function tobuff4() public view returns(uint256) {
        return (self & 22213632912598862894889094373145828843847680) >>136; //0xFF0000000000000000000000000000000000
    }
    function toDebuff5() public view returns(uint256) {
        return (self & 86772003564839308183160524895100893921280) >>128; //0xFF00000000000000000000000000000000
    }
    function tobuff5() public view returns(uint256) {
        return (self & 338953138925153547590470800371487866880) >>120; //0xFF000000000000000000000000000000
    }
    //features
    function toHp() public view returns(uint256) {
        return (self & 1329226728134315644674405563577139200) >>100;   //0xFFFFF0000000000000000000000000
    }
    function toAp() public view returns(uint256) {
        return (self & 1267649391302409786867528499200) >>80; //0xFFFFF00000000000000000000
    }
    function toDeff() public view returns(uint256) {
        return (self & 1208924666693124567859200) >>60; //0xFFFFF000000000000000
    }
    function toSpeed() public view returns(uint256) {
        return (self & 1152920405095219200) >>40; //0xFFFFF0000000000
    }
    function toWeight() public view returns(uint256) {
        return (self & 1099510579200) >>20; //0xFFFFF00000
    }
    function toLifeSpan() public view returns(uint256) {
        return (self & 1048575) ; //0xFFFFF
    }
    
    function toMask(uint256 _mask ) public pure returns(uint256) {
        return _mask ;
    }
    
}


pragma solidity ^0.4.21;

contract Bitwise {
    
    uint256[] public val;
    
    function Bitwise() public {
        val.push(1);    
        val.push(483122250857357694405257107524222366032853776359798369891734432751026236);    
    }
    //         rrRRRRRRRRb5b5b4b4b3b3b2b2b1b1HHHHHAAAAADDDDDSSSSSWWWWWLLLLL    
    //input: 0x46000010000000000000050000000002710003e80012c00050017700003c
    //val : 483122250857357694405257107524222366032853776359798369891734432751026236
    //ok.
    function addVal(uint256 _val ) public {
        val.push(_val);
    }
    //rarity //total:240
    function toRarity() public view returns(uint256) {
        return (self & 1759945318431593765795862744880641490375032787903448571566443677068820480) >>232; //0xFF0000000000000000000000000000000000000000000000000000000000
    }
    //regions
    function toRegion1() public view returns(uint256) {
        return (self & 6470387200116153550720083620884711361672914661409737395464866459811840) >>228; //0xF000000000000000000000000000000000000000000000000000000000
    }
    function toRegion2() public view returns(uint256) {
        return (self & 404399200007259596920005226305294460104557166338108587216554153738240) >>224; //0xF00000000000000000000000000000000000000000000000000000000
    }
    function toRegion3() public view returns(uint256) {
        return (self & 25274950000453724807500326644080903756534822896131786701034634608640) >>220; //0xF0000000000000000000000000000000000000000000000000000000
    }
    function toRegion4() public view returns(uint256) {
        return (self & 1579684375028357800468770415255056484783426431008236668814664663040) >>216; //0xF000000000000000000000000000000000000000000000000000000
    }
    function toRegion5() public view returns(uint256) {
        return (self & 98730273439272362529298150953441030298964151938014791800916541440) >>212; //0xF00000000000000000000000000000000000000000000000000000
    }
    function toRegion6() public view returns(uint256) {
        return (self & 6170642089954522658081134434590064393685259496125924487557283840) >>208; //0xF0000000000000000000000000000000000000000000000000000
    }
    function toRegion7() public view returns(uint256) {
        return (self & 385665130622157666130070902161879024605328718507870280472330240) >>204; //0xF000000000000000000000000000000000000000000000000000
    }
    function toRegion8() public view returns(uint256) {
        return (self & 24104070663884854133129431385117439037833044906741892529520640) >>200; //0xF00000000000000000000000000000000000000000000000000
    }

    function toDebuff1() public view returns(uint256) {
        return (self & 1600660942523603594778126302917954936106100638338328800788480) >>192; //0xFF000000000000000000000000000000000000000000000000
    }
    function tobuff1() public view returns(uint256) {
        return (self & 6252581806732826542102055870773261469164455618509096878080) >>184; //0xFF0000000000000000000000000000000000000000000000
    }
    function toDebuff2() public view returns(uint256) {
        return (self & 24424147682550103680086155745208052613923654759801159680) >>176; //0xFF00000000000000000000000000000000000000000000
    }
    function tobuff2() public view returns(uint256) {
        return (self & 95406826884961342500336545879718955523139276405473280) >>168; //0xFF000000000000000000000000000000000000000000
    }
    function toDebuff3() public view returns(uint256) {
        return (self & 372682917519380244141939632342652170012262798458880) >>160; //0xFF0000000000000000000000000000000000000000
    }
    function tobuff3() public view returns(uint256) {
        return (self & 1455792646560079078679451688838485039110401556480) >>152; //0xFF00000000000000000000000000000000000000
    }
    function toDebuff4() public view returns(uint256) {
        return (self & 5686690025625308901091608159525332184025006080) >>144; //0xFF000000000000000000000000000000000000
    }
    function tobuff4() public view returns(uint256) {
        return (self & 22213632912598862894889094373145828843847680) >>136; //0xFF0000000000000000000000000000000000
    }
    function toDebuff5() public view returns(uint256) {
        return (self & 86772003564839308183160524895100893921280) >>128; //0xFF00000000000000000000000000000000
    }
    function tobuff5() public view returns(uint256) {
        return (self & 338953138925153547590470800371487866880) >>120; //0xFF000000000000000000000000000000
    }
    //features
    function toHp() public view returns(uint256) {
        return (self & 1329226728134315644674405563577139200) >>100;   //0xFFFFF0000000000000000000000000
    }
    function toAp() public view returns(uint256) {
        return (self & 1267649391302409786867528499200) >>80; //0xFFFFF00000000000000000000
    }
    function toDeff() public view returns(uint256) {
        return (self & 1208924666693124567859200) >>60; //0xFFFFF000000000000000
    }
    function toSpeed() public view returns(uint256) {
        return (self & 1152920405095219200) >>40; //0xFFFFF0000000000
    }
    function toWeight() public view returns(uint256) {
        return (self & 1099510579200) >>20; //0xFFFFF00000
    }
    function toLifeSpan() public view returns(uint256) {
        return (self & 1048575) ; //0xFFFFF
    }
    
    function toMask(uint256 _mask ) public pure returns(uint256) {
        return _mask ;
    }
    
}*/