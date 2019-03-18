/**
* @dev return the price buyer will pay for next 1 individual key.
* -functionhash- 0x018a25e8
* @return price for next key bought (in wei format)
*/
function getBuyPrice()
    public 
    view 
    returns(uint256)
{  
    // setup local rID
    uint256 _rID = rID_;
    
    // grab time
    uint256 _now = now;
    
    // are we in a round?
    if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );  // 1ETH
    else // rounds over.  need price for new round
        return ( 75000000000000 ); // init
}
    
/**
* @dev distributes eth based on fees to com, aff, and p3d
*/
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
    private
    returns(F3Ddatasets.EventReturns)
{
    // pay 2% out to community rewards
    uint256 _com = _eth / 50;
    uint256 _p3d;
    if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()"))))
    {
        // This ensures Team Just cannot influence the outcome of FoMo3D with
        // bank migrations by breaking outgoing transactions.
        // Something we would never do. But that's not the point.
        // We spent 2000$ in eth re-deploying just to patch this, we hold the 
        // highest belief that everything we create should be trustless.
        // Team JUST, The name you shouldn't have to trust.
        _p3d = _com;
        _com = 0;
    }
    
    // pay 1% out to FoMo3D short
    uint256 _long = _eth / 100;
    otherF3D_.potSwap.value(_long)();
    
    // distribute share to affiliate
    uint256 _aff = _eth / 10;
    
    // decide what to do with affiliate share of fees
    // affiliate must not be self, and must have a name registered
    if (_affID != _pID && plyr_[_affID].name != '') {
        plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
        emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
    } else {
        _p3d = _aff;
    }
    
    // pay out p3d
    _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
    if (_p3d > 0)
    {
        // deposit to divies contract
        Divies.deposit.value(_p3d)();
        
        // set up event data
        _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
    }
    
    return(_eventData_);
}

/**
    * @dev updates masks for round and player when keys are bought
    * @return dust left over 
    */
function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
    private
    returns(uint256)
{
    /* MASKING NOTES
        earnings masks are a tricky thing for people to wrap their minds around.
        the basic thing to understand here.  is were going to have a global
        tracker based on profit per share for each round, that increases in
        relevant proportion to the increase in share supply.
        
        the player will have an additional mask that basically says "based
        on the rounds mask, my shares, and how much i've already withdrawn,
        how much is still owed to me?"
    */
    // 对人们来说，获得 mask 是一件棘手的事情
    // 这里要理解的最基本的东西 将会有一个基于每股利润的全球跟踪器 每一轮的利润增长与股票供应量的增加相关。
    
    // calc profit per key & round mask based on this buy:  (dust goes to pot)
    uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
    round_[_rID].mask = _ppt.add(round_[_rID].mask);
        
    // calculate player earning from their own buy (only based on the keys
    // they just bought).  & update player earnings mask
    uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
    plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
    
    // calculate & return dust
    return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
}

library F3DKeysCalcLong {
    using SafeMath for *;
    /**
     * @dev calculates number of keys received given X eth 
     * @param _curEth current amount of eth in contract 
     * @param _newEth eth being spent
     * @return amount of ticket purchased
     */
    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }
    
    /**
     * @dev calculates amount of eth received if you sold X keys 
     * @param _curKeys current amount of keys that exist 
     * @param _sellKeys amount of keys you wish to sell
     * @return amount of eth received
     */
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    /**
     * @dev calculates how many keys would exist with given an amount of eth
     * @param _eth eth "in contract"
     * @return number of keys that would exist
     */
    function keys(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    /**
     * @dev calculates how much eth would be in contract given a number of keys
     * @param _keys number of keys "in contract" 
     * @return eth that would exists
     */
    function eth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}