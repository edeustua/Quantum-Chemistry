function [HBar_t] = build_hbar_ccs_debug(t1a,t1b,sys)

    % h(ov)
    H1A.ov = sys.fa_ov...
             +einsum_kg(sys.vA_oovv,t1a,'mnef,fn->me')...
             +einsum_kg(sys.vB_oovv,t1b,'mnef,fn->me');  
         
    H1B.ov = sys.fb_ov...
             +einsum_kg(sys.vB_oovv,t1a,'nmfe,fn->me')...
             +einsum_kg(sys.vC_oovv,t1b,'mnef,fn->me');
         
    % h(oo)
    H1A.oo = sys.fa_oo...
             +einsum_kg(H1A.ov,t1a,'me,ei->mi')...
             +einsum_kg(sys.vA_ooov,t1a,'mnif,fn->mi')...
             +einsum_kg(sys.vB_ooov,t1b,'mnif,fn->mi');
         
    H1B.oo = sys.fb_oo...
             +einsum_kg(H1B.ov,t1b,'me,ei->mi')...
             +einsum_kg(sys.vB_oovo,t1a,'nmfi,fn->mi')...
             +einsum_kg(sys.vC_ooov,t1b,'mnif,fn->mi');
         
    % h(vv)
    H1A.vv = sys.fa_vv...
             -einsum_kg(H1A.ov,t1a,'me,am->ae')...
             +einsum_kg(sys.vA_vovv,t1a,'amef,fm->ae')...
             +einsum_kg(sys.vB_vovv,t1b,'anef,fn->ae');
         
    H1B.vv = sys.fb_vv...
             -einsum_kg(H1B.ov,t1b,'me,am->ae')...
             +einsum_kg(sys.vB_ovvv,t1a,'nafe,fn->ae')...
             +einsum_kg(sys.vC_vovv,t1b,'anef,fn->ae');
         
    % h(vovv)
    H2A.vovv = sys.vA_vovv - einsum_kg(sys.vA_oovv,t1a,'mnfe,an->amef');
    
    H2B.vovv = sys.vB_vovv - einsum_kg(sys.vB_oovv,t1a,'nmef,an->amef');
    
    H2B.ovvv = sys.vB_ovvv - einsum_kg(sys.vB_oovv,t1b,'mnfe,an->mafe');
    
    H2C.vovv = sys.vC_vovv - einsum_kg(sys.vC_oovv,t1b,'mnfe,an->amef');
    
    % h(ooov)
    H2A.ooov = sys.vA_ooov + einsum_kg(sys.vA_oovv,t1a,'mnfe,fi->mnie');
    
    H2B.ooov = sys.vB_ooov + einsum_kg(sys.vB_oovv,t1a,'mnfe,fi->mnie');
    
    H2B.oovo = sys.vB_oovo + einsum_kg(sys.vB_oovv,t1b,'nmef,fi->nmei');
    
    H2C.ooov = sys.vC_ooov + einsum_kg(sys.vC_oovv,t1b,'mnfe,fi->mnie');
    
    % h(oooo)
    H2A.oooo = sys.vA_oooo...
                +einsum_kg(sys.vA_oovo,t1a,'mnej,ei->mnij')...
	     			-einsum_kg(sys.vA_oovo,t1a,'mnei,ej->mnij')...
                +einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,ei->mnif'),t1a,'mnif,fj->mnij');
        
    H2B.oooo =  sys.vB_oooo...
                +einsum_kg(sys.vB_oovo,t1a,'mnej,ei->mnij')...
                +einsum_kg(sys.vB_ooov,t1b,'mnif,fj->mnij')...
                +einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,ei->mnif'),t1b,'mnif,fj->mnij'); 
            
    H2C.oooo = sys.vC_oooo...
                +einsum_kg(sys.vC_ooov,t1b,'mnie,ej->mnij')...
	    			-einsum_kg(sys.vC_ooov,t1b,'mnje,ei->mnij')...
                +einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,ei->mnif'),t1b,'mnif,fj->mnij'); 
        
    % h(vvvv)
    H2A.vvvv = sys.vA_vvvv...
                -einsum_kg(sys.vA_ovvv,t1a,'mbef,am->abef')...
	     			+einsum_kg(sys.vA_ovvv,t1a,'maef,bm->abef')...
                +einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,bn->mbef'),t1a,'mbef,am->abef');
            
    H2B.vvvv =  sys.vB_vvvv...
                -einsum_kg(sys.vB_ovvv,t1a,'mbef,am->abef')...
                -einsum_kg(sys.vB_vovv,t1b,'anef,bn->abef')...
                +einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,am->anef'),t1b,'anef,bn->abef');
            
    H2C.vvvv = sys.vC_vvvv...
                -einsum_kg(sys.vC_ovvv,t1b,'mbef,am->abef')...
	     			+einsum_kg(sys.vC_ovvv,t1b,'maef,bm->abef')...
                +einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,bn->mbef'),t1b,'mbef,am->abef');
        
    % h(voov)
    H2A.voov = sys.vA_voov ...
               -einsum_kg(sys.vA_ooov,t1a,'nmie,an->amie')...
               +einsum_kg(sys.vA_vovv,t1a,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vA_oovv,t1a,'nmfe,fi->nmie'),t1a,'nmie,an->amie');
            
    H2B.voov = sys.vB_voov ...
               -einsum_kg(sys.vB_ooov,t1a,'nmie,an->amie')...
               +einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1a,'nmfe,fi->nmie'),t1a,'nmie,an->amie');
           
    H2B.ovov = sys.vB_ovov ...
               +einsum_kg(sys.vB_ovvv,t1a,'mafe,fi->maie')...
               -einsum_kg(sys.vB_ooov,t1b,'mnie,an->maie')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnfe,an->mafe'),t1a,'mafe,fi->maie');
           
    H2B.vovo = sys.vB_vovo ...
               -einsum_kg(sys.vB_oovo,t1a,'nmei,an->amei')...
               +einsum_kg(sys.vB_vovv,t1b,'amef,fi->amei')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'nmef,fi->nmei'),t1a,'nmei,an->amei');
           
    H2B.ovvo = sys.vB_ovvo ...
               +einsum_kg(sys.vB_ovvv,t1b,'maef,fi->maei')...
               -einsum_kg(sys.vB_oovo,t1b,'mnei,an->maei')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,fi->mnei'),t1b,'mnei,an->maei');
           
    H2C.voov = sys.vC_voov ...
               -einsum_kg(sys.vC_oovo,t1b,'mnei,an->amie')...
               +einsum_kg(sys.vC_vovv,t1b,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,fi->mnei'),t1b,'mnei,an->amie');
    
    % h(vooo)
    H2A.vooo    = sys.vA_vooo ...
                  +einsum_kg(sys.vA_voov,t1a,'amie,ej->amij')...
	    			-einsum_kg(sys.vA_voov,t1a,'amje,ei->amij')...
                  -einsum_kg(sys.vA_oooo,t1a,'nmij,an->amij')...
                  -einsum_kg(einsum_kg(sys.vA_oovo,t1a,'nmej,ei->nmij'),t1a,'nmij,an->amij')...
	    			+einsum_kg(einsum_kg(sys.vA_oovo,t1a,'nmei,ej->nmij'),t1a,'nmij,an->amij')...
                  +einsum_kg(einsum_kg(sys.vA_vovv,t1a,'amef,ei->amif'),t1a,'amif,fj->amij')...
                  -einsum_kg(einsum_kg(einsum_kg(sys.vA_oovv,t1a,'nmef,fj->nmej'),t1a,'nmej,an->amej'),t1a,'amej,ei->amij');
              
    H2B.vooo = sys.vB_vooo...
               -einsum_kg(sys.vB_oooo,t1a,'nmij,an->amij')...
               +einsum_kg(sys.vB_vovo,t1a,'amej,ei->amij')...
               +einsum_kg(sys.vB_voov,t1b,'amie,ej->amij')...
               -einsum_kg(einsum_kg(sys.vB_oovo,t1a,'nmej,an->amej'),t1a,'amej,ei->amij')...
               -einsum_kg(einsum_kg(sys.vB_ooov,t1b,'nmie,ej->nmij'),t1a,'nmij,an->amij')...
               -einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1b,'nmfe,ej->nmfj'),t1a,'nmfj,an->amfj'),t1a,'amfj,fi->amij')...
               +einsum_kg(einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie'),t1b,'amie,ej->amij');
           
    H2B.ovoo =  sys.vB_ovoo...
                +einsum_kg(sys.vB_ovvo,t1a,'maei,ej->maji')...
                -einsum_kg(sys.vB_oooo,t1b,'mnji,an->maji')...
                +einsum_kg(sys.vB_ovov,t1b,'majf,fi->maji')...
                -einsum_kg(einsum_kg(sys.vB_ooov,t1b,'mnjf,an->majf'),t1b,'majf,fi->maji')...
                +einsum_kg(einsum_kg(sys.vB_ovvv,t1a,'maef,ej->majf'),t1b,'majf,fi->maji')...
                -einsum_kg(einsum_kg(sys.vB_oovo,t1a,'mnei,ej->mnji'),t1b,'mnji,an->maji')...
                -einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,ej->mnjf'),t1b,'mnjf,an->majf'),t1b,'majf,fi->maji');
            
    H2C.vooo =  sys.vC_vooo ...
                +einsum_kg(sys.vC_vovo,t1b,'amej,ei->amij')...
	    			-einsum_kg(sys.vC_vovo,t1b,'amei,ej->amij')...
                -einsum_kg(sys.vC_oooo,t1b,'nmij,an->amij')...
                -einsum_kg(einsum_kg(sys.vC_ooov,t1b,'mnjf,an->majf'),t1b,'majf,fi->amij')...
	    			+einsum_kg(einsum_kg(sys.vC_ooov,t1b,'mnif,an->maif'),t1b,'maif,fj->amij')...
                +einsum_kg(einsum_kg(sys.vC_vovv,t1b,'amfe,fi->amie'),t1b,'amie,ej->amij')...
                -einsum_kg(einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,ej->mnjf'),t1b,'mnjf,fi->mnji'),t1b,'mnji,an->amij');
              
    % h(vvov)
    H2A.vvov  = sys.vA_vvov ...
                +einsum_kg(sys.vA_vvvv,t1a,'abfe,fi->abie')...
                -einsum_kg(sys.vA_ovov,t1a,'nbie,an->abie')...
	    			+einsum_kg(sys.vA_ovov,t1a,'naie,bn->abie')...
                +einsum_kg(einsum_kg(sys.vA_oovo,t1a,'mnei,an->maei'),t1a,'maei,bm->abie')...
                -einsum_kg(einsum_kg(sys.vA_vovv,t1a,'bnef,fi->bnei'),t1a,'bnei,an->abie')...
	    			+einsum_kg(einsum_kg(sys.vA_vovv,t1a,'anef,fi->anei'),t1a,'anei,bn->abie')...
                +einsum_kg(einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,bm->bnef'),t1a,'bnef,an->baef'),t1a,'baef,fi->abie');
            
    H2B.vvov =  sys.vB_vvov...
                -einsum_kg(sys.vB_ovov,t1a,'nbie,an->abie')...
                +einsum_kg(sys.vB_vvvv,t1a,'abfe,fi->abie')...
                -einsum_kg(sys.vB_voov,t1b,'amie,bm->abie')...
                -einsum_kg(einsum_kg(sys.vB_ovvv,t1a,'nbfe,an->abfe'),t1a,'abfe,fi->abie')...
                +einsum_kg(einsum_kg(sys.vB_ooov,t1a,'nmie,an->amie'),t1b,'amie,bm->abie')...
                -einsum_kg(einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie'),t1b,'amie,bm->abie')...
                +einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1a,'nmfe,an->amfe'),t1a,'amfe,fi->amie'),t1b,'amie,bm->abie');
            
    H2B.vvvo =  sys.vB_vvvo...
                +einsum_kg(sys.vB_vvvv,t1b,'baef,fi->baei')...
                -einsum_kg(sys.vB_vovo,t1b,'bnei,an->baei')...
                -einsum_kg(sys.vB_ovvo,t1a,'maei,bm->baei')...
                -einsum_kg(einsum_kg(sys.vB_vovv,t1b,'bnef,fi->bnei'),t1b,'bnei,an->baei')...
                +einsum_kg(einsum_kg(sys.vB_oovo,t1b,'mnei,an->maei'),t1a,'maei,bm->baei')...
                -einsum_kg(einsum_kg(sys.vB_ovvv,t1b,'maef,fi->maei'),t1a,'maei,bm->baei')...
                +einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,an->maef'),t1b,'maef,fi->maei'),t1a,'maei,bm->baei');
            
     H2C.vvov =  sys.vC_vvov...
                +einsum_kg(sys.vC_vvvv,t1b,'abfe,fi->abie')...
                -einsum_kg(sys.vC_ovov,t1b,'nbie,an->abie')...
	    			+einsum_kg(sys.vC_ovov,t1b,'naie,bn->abie')...
                -einsum_kg(einsum_kg(sys.vC_ovvv,t1b,'nbfe,an->abfe'),t1b,'abfe,fi->abie')...
	    			+einsum_kg(einsum_kg(sys.vC_ovvv,t1b,'nafe,bn->bafe'),t1b,'bafe,fi->abie')...
                +einsum_kg(einsum_kg(sys.vC_oovo,t1b,'mnei,bm->bnei'),t1b,'bnei,an->abie')...
                +einsum_kg(einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,bm->bnef'),t1b,'bnef,an->baef'),t1b,'baef,fi->abie');
    
    % store HBar into HBar_t struct
    HBar_t.H1A = H1A;
    HBar_t.H1B = H1B;
    HBar_t.H2A = H2A;
    HBar_t.H2B = H2B;
    HBar_t.H2C = H2C;
    
end

