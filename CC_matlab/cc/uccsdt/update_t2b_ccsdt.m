function [t2b] = update_t2b_ccsdt(t1a,t1b,t2a,t2b,t2c,t3a,t3b,t3c,t3d,HBar_t,sys,shift)

    % MM12 contribution
    d1 = sys.vB_ovoo;
    d2 = einsum_kg(sys.vB_ovvo,t1a,'mbej,ei->mbij');
    d3 = -einsum_kg(sys.vB_oooo,t1b,'mnij,bn->mbij');
    d4 = -einsum_kg(einsum_kg(sys.vB_ooov,t1b,'mnif,bn->mbif'),t1b,'mbif,fj->mbij');
    d5 = -einsum_kg(einsum_kg(sys.vB_oovo,t1b,'mnej,bn->mbej'),t1a,'mbej,ei->mbij');
    d6 = einsum_kg(einsum_kg(sys.vB_ovvv,t1b,'mbef,fj->mbej'),t1a,'mbej,ei->mbij');
    
    h2B_ovoo = d1 + d2 + d3 + d4 + d5 + d6;
    
    d1 = sys.vB_vooo;
    d2 = einsum_kg(sys.vB_voov,t1b,'amif,fj->amij');
    d3 = -einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1a,'nmef,an->amef'),t1a,'amef,ei->amif'),t1b,'amif,fj->amij');
    d4 = einsum_kg(einsum_kg(sys.vB_vovv,t1b,'amef,fj->amej'),t1a,'amej,ei->amij');
    
    h2B_vooo = d1 + d2 + d3 + d4;
    
    d1 = sys.vB_vvvo;
    d2 = einsum_kg(sys.vB_vvvv,t1b,'abef,fj->abej');
    d3 = -einsum_kg(sys.vB_vovo,t1b,'anej,bn->abej');
    
    h2B_vvvo = d1 + d2 + d3;
     
    d1 = sys.vB_vvov;
    d2 = -einsum_kg(sys.vB_ovov,t1a,'mbie,am->abie');
    
    h2B_vvov = d1 + d2;
     
    D1 = -einsum_kg(h2B_ovoo,t1a,'mbij,am->abij');
    D2 = -einsum_kg(h2B_vooo,t1b,'amij,bm->abij');
    D3 = einsum_kg(h2B_vvvo,t1a,'abej,ei->abij');
    D4 = einsum_kg(h2B_vvov,t1b,'abie,ej->abij');
    
    MM12B = sys.vB_vvoo + D1 + D2 + D3 + D4;

    % CCS HBar elements
    h1A_ov = sys.fa_ov...
             +einsum_kg(sys.vA_oovv,t1a,'mnef,fn->me')...
             +einsum_kg(sys.vB_oovv,t1b,'mnef,fn->me');  
         
    h1B_ov = sys.fb_ov...
             +einsum_kg(sys.vB_oovv,t1a,'nmfe,fn->me')...
             +einsum_kg(sys.vC_oovv,t1b,'mnef,fn->me');

    h1A_oo = sys.fa_oo_masked...
             +einsum_kg(h1A_ov,t1a,'me,ei->mi')...
             +einsum_kg(sys.vA_ooov,t1a,'mnif,fn->mi')...
             +einsum_kg(sys.vB_ooov,t1b,'mnif,fn->mi');
         
    h1B_oo = sys.fb_oo_masked...
             +einsum_kg(h1B_ov,t1b,'me,ei->mi')...
             +einsum_kg(sys.vB_oovo,t1a,'nmfi,fn->mi')...
             +einsum_kg(sys.vC_ooov,t1b,'mnif,fn->mi');
         
    h1A_vv = sys.fa_vv_masked...
             -einsum_kg(h1A_ov,t1a,'me,am->ae')...
             +einsum_kg(sys.vA_vovv,t1a,'amef,fm->ae')...
             +einsum_kg(sys.vB_vovv,t1b,'anef,fn->ae');
         
    h1B_vv = sys.fb_vv_masked...
             -einsum_kg(h1B_ov,t1b,'me,am->ae')...
             +einsum_kg(sys.vB_ovvv,t1a,'nafe,fn->ae')...
             +einsum_kg(sys.vC_vovv,t1b,'anef,fn->ae');
        
    h2B_oooo =  sys.vB_oooo...
                +einsum_kg(sys.vB_oovo,t1a,'mnej,ei->mnij')...
                +einsum_kg(sys.vB_ooov,t1b,'mnif,fj->mnij')...
                +einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,ei->mnif'),t1b,'mnif,fj->mnij'); 
            
    h2B_vvvv =  sys.vB_vvvv...
                -einsum_kg(sys.vB_ovvv,t1a,'mbef,am->abef')...
                -einsum_kg(sys.vB_vovv,t1b,'anef,bn->abef')...
                +einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,am->anef'),t1b,'anef,bn->abef');
        
    h2A_voov = sys.vA_voov ...
               -einsum_kg(sys.vA_ooov,t1a,'nmie,an->amie')...
               +einsum_kg(sys.vA_vovv,t1a,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vA_oovv,t1a,'nmfe,fi->nmie'),t1a,'nmie,an->amie');
            
    h2B_voov = sys.vB_voov ...
               -einsum_kg(sys.vB_ooov,t1a,'nmie,an->amie')...
               +einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1a,'nmfe,fi->nmie'),t1a,'nmie,an->amie');
           
    h2B_ovov = sys.vB_ovov ...
               +einsum_kg(sys.vB_ovvv,t1a,'mafe,fi->maie')...
               -einsum_kg(sys.vB_ooov,t1b,'mnie,an->maie')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnfe,an->mafe'),t1a,'mafe,fi->maie');
           
    h2B_vovo = sys.vB_vovo ...
               -einsum_kg(sys.vB_oovo,t1a,'nmei,an->amei')...
               +einsum_kg(sys.vB_vovv,t1b,'amef,fi->amei')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'nmef,fi->nmei'),t1a,'nmei,an->amei');
           
    h2B_ovvo = sys.vB_ovvo ...
               +einsum_kg(sys.vB_ovvv,t1b,'maef,fi->maei')...
               -einsum_kg(sys.vB_oovo,t1b,'mnei,an->maei')...
               -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,fi->mnei'),t1b,'mnei,an->maei');
           
    h2C_voov = sys.vC_voov ...
               -einsum_kg(sys.vC_oovo,t1b,'mnei,an->amie')...
               +einsum_kg(sys.vC_vovv,t1b,'amfe,fi->amie')...
               -einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,fi->mnei'),t1b,'mnei,an->amie');
    
    % <ijab|[H(CCS)*T2]_C + [H(CCS)*T2^2]_C|0>
    VT2_1A_vv = -0.5*einsum_kg(sys.vA_oovv,t2a,'mnef,afmn->ae') - einsum_kg(sys.vB_oovv,t2b,'mnef,afmn->ae');
    VT2_1B_vv = -einsum_kg(sys.vB_oovv,t2b,'nmfe,fbnm->be') - 0.5*einsum_kg(sys.vC_oovv,t2c,'mnef,fbnm->be');
    VT2_1A_oo = 0.5*einsum_kg(sys.vA_oovv,t2a,'mnef,efin->mi') + einsum_kg(sys.vB_oovv,t2b,'mnef,efin->mi');
    VT2_1B_oo = einsum_kg(sys.vB_oovv,t2b,'nmfe,fenj->mj') + 0.5*einsum_kg(sys.vC_oovv,t2c,'mnef,efjn->mj');
    
    VT2_2A_voov = einsum_kg(sys.vA_oovv,t2a,'mnef,aeim->anif') + einsum_kg(sys.vB_oovv,t2b,'nmfe,aeim->anif');
    VT2_2B_voov = einsum_kg(sys.vB_oovv,t2a,'mnef,aeim->anif') + einsum_kg(sys.vC_oovv,t2b,'mnef,aeim->anif');
    VT2_2B_oooo = einsum_kg(sys.vB_oovv,t2b,'mnef,efij->mnij');
    VT2_2B_vovo = -einsum_kg(sys.vB_oovv,t2b,'mnef,afmj->anej');
    
    D5 = einsum_kg(h1A_vv + VT2_1A_vv,t2b,'ae,ebij->abij');
    
    D6 = einsum_kg(h1B_vv + VT2_1B_vv,t2b,'be,aeij->abij');
    
    D7 = -einsum_kg(h1A_oo + VT2_1A_oo,t2b,'mi,abmj->abij');
    
    D8 = -einsum_kg(h1B_oo + VT2_1B_oo,t2b,'mj,abim->abij');
    
    D9 = einsum_kg(h2A_voov + VT2_2A_voov,t2b,'amie,ebmj->abij');
    
    D10 = einsum_kg(h2B_voov + VT2_2B_voov,t2c,'amie,ebmj->abij');
    
    D11 = einsum_kg(h2B_ovvo,t2a,'mbej,aeim->abij');
    
    D12 = einsum_kg(h2C_voov,t2b,'bmje,aeim->abij');
    
    D13 = -einsum_kg(h2B_ovov,t2b,'mbie,aemj->abij');
    
    D14 = -einsum_kg(h2B_vovo + VT2_2B_vovo,t2b,'amej,ebim->abij');
    
    D15 = einsum_kg(h2B_oooo + VT2_2B_oooo,t2b,'mnij,abmn->abij');
    
    D16 = einsum_kg(h2B_vvvv,t2b,'abef,efij->abij');
    
    CCS_T2 = D5 + D6 + D7 + D8 + D9 + D10 + D11 + D12 + D13 + D14 + D15 + D16;
    
    X2B = MM12B + CCS_T2;
    
    % CCSDT part
    H1A = HBar_t.H1A;
    H1B = HBar_t.H1B;
    H2A = HBar_t.H2A;
    H2B = HBar_t.H2B;
    H2C = HBar_t.H2C;
    
    TR_D1 = -0.5*einsum_kg(H2A.ooov,t3b,'mnif,afbmnj->abij');
    TR_D2 = -einsum_kg(H2B.oovo,t3b,'nmfj,afbinm->abij');
    TR_D3 = -0.5*einsum_kg(H2C.ooov,t3c,'mnjf,afbinm->abij');
    TR_D4 = -einsum_kg(H2B.ooov,t3c,'mnif,afbmnj->abij');
    TR_D5 = +0.5*einsum_kg(H2A.vovv,t3b,'anef,efbinj->abij');
    TR_D6 = +einsum_kg(H2B.vovv,t3c,'anef,efbinj->abij');
    TR_D7 = +einsum_kg(H2B.ovvv,t3b,'nbfe,afeinj->abij');
    TR_D8 = +0.5*einsum_kg(H2C.vovv,t3c,'bnef,afeinj->abij');
    TR_D9 = +einsum_kg(H1A.ov,t3b,'me,aebimj->abij');
    TR_D10 = +einsum_kg(H1B.ov,t3c,'me,aebimj->abij');
    
    X2B = X2B + TR_D1 + TR_D2 + TR_D3 + TR_D4 + TR_D5 + TR_D6 + TR_D7 + TR_D8 + TR_D9 + TR_D10;
    
    for i = 1:sys.Nocc_alpha
        for j = 1:sys.Nocc_beta
            for a = 1:sys.Nvir_alpha
                for b = 1:sys.Nvir_beta
                    denom = (sys.fa_oo(i,i)+sys.fb_oo(j,j)-sys.fa_vv(a,a)-sys.fb_vv(b,b)-shift); 
                    t2b(a,b,i,j) = X2B(a,b,i,j) / denom;
                end
            end
        end
    end
    
end
