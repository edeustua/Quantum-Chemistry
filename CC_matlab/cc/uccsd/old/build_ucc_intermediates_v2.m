function [chi1A, chi1B, chi2A, chi2B, chi2C] = build_ucc_intermediates_v2(t1a, t1b, t2a, t2b, t2c, sys)

% 1-body intermediates

chi1A.me = sys.fa_ov ...
           + einsum_kg(sys.vA_oovv,t1a,'mnef,fn->me')...
           + einsum_kg(sys.vB_oovv,t1b,'mnef,fn->me');
tempA_mi = einsum_kg(chi1A.me,t1a,'me,ei->mi');
tempA_ab = -einsum_kg(chi1A.me,t1a,'mb,am->ab');

chi1B.me = sys.fb_ov...
           + einsum_kg(sys.vC_oovv,t1b,'nmfe,fn->me') ...
           + einsum_kg(sys.vB_oovv,t1a,'nmfe,fn->me');
tempB_mj = einsum_kg(chi1B.me,t1b,'me,ej->mj');
tempB_be = -einsum_kg(chi1B.me,t1b,'mb,am->ab');

chi1A.mi = sys.fa_oo_masked +...
         einsum_kg(sys.vA_ooov,t1a,'mnif,fn->mi') +...
         einsum_kg(sys.vB_ooov,t1b,'mnif,fn->mi') +...
         0.5*einsum_kg(sys.vA_oovv,t2a,'mnef,efin->mi') + ...
         einsum_kg(sys.vB_oovv,t2b,'mnef,efin->mi') ...
         +tempA_mi;

chi1A.mi_bar = chi1A.mi - 0.5*tempA_mi;

chi1B.mj = sys.fb_oo_masked +...
         einsum_kg(sys.vC_ooov,t1b,'mnje,en->mj') +...
         einsum_kg(sys.vB_oovo,t1a,'nmej,en->mj') +...
         0.5*einsum_kg(sys.vC_oovv,t2c,'nmfe,fenj->mj') + ...
         einsum_kg(sys.vB_oovv,t2b,'nmfe,fenj->mj') ...
         +tempB_mj;

chi1B.mj_bar = chi1B.mj - 0.5*tempB_mj;

chi1A.ae = sys.fa_vv_masked + ...
           einsum_kg(sys.vA_vovv,t1a,'anef,fn->ae') +...
           einsum_kg(sys.vB_vovv,t1b,'anef,fn->ae') -...
           0.5*einsum_kg(sys.vA_oovv,t2a,'mnef,afmn->ae') -...
           einsum_kg(sys.vB_oovv,t2b,'mnef,afmn->ae') ...
           +tempA_ab;

chi1A.ae_bar = chi1A.ae - 0.5*tempA_ab;

chi1B.be = sys.fb_vv_masked + ...
           einsum_kg(sys.vC_ovvv,t1b,'nbfe,fn->be') +...
           einsum_kg(sys.vB_ovvv,t1a,'nbfe,fn->be') -...
           0.5*einsum_kg(sys.vC_oovv,t2c,'nmfe,fbnm->be') -...
           einsum_kg(sys.vB_oovv,t2b,'nmfe,fbnm->be') ...
           +tempB_be;

chi1B.be_bar = chi1B.be - 0.5*tempB_be;

% 2-body intermediates

% VT2 terms
VAT2A = einsum_kg(sys.vA_oovv,t2a,'mnef,aeim->anif');
VBT2B = einsum_kg(sys.vB_oovv,t2b,'nmfe,aeim->anif');
VCT2B = einsum_kg(sys.vC_oovv,t2b,'mnef,aeim->anif');
VBT2A = einsum_kg(sys.vB_oovv,t2a,'nmfe,afin->amie');

% chiA
chi2A.amie_bar = sys.vA_voov ...
                 +einsum_kg(sys.vA_vovv,t1a,'amfe,fi->amie') ...
                 -einsum_kg(sys.vA_ooov,t1a,'nmie,an->amie') ...
                 -einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,an->maef'),t1a,'maef,fi->amie') ...
                 +0.5*VAT2A ...
                 +0.5*VBT2B;
             
chi2A.amie = chi2A.amie_bar ...
             +0.5*VAT2A ...
             +0.5*VBT2B;

chi2A.mnij = sys.vA_oooo ...
             +einsum_kg(sys.vA_oovo,t1a,'mnej,ei->mnij') ...
             -einsum_kg(sys.vA_oovo,t1a,'mnei,ej->mnij') ...
             +0.5*einsum_kg(sys.vA_oovv,t2a,'mnef,efij->mnij') ...
             +einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,ei->mnif'),t1a,'mnif,fj->mnij');
         
chi2A.abef = sys.vA_vvvv  ...
             -einsum_kg(sys.vA_ovvv,t1a,'mbef,am->abef') ...
             +einsum_kg(sys.vA_ovvv,t1a,'maef,bm->abef') ...
             +einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,am->anef'),t1a,'anef,bn->abef');

chi2A.mbij = sys.vA_ovoo ...
             +einsum_kg(sys.vA_ovvo,t1a,'mbej,ei->mbij') ...
             -einsum_kg(sys.vA_ovvo,t1a,'mbei,ej->mbij') ...
             -0.5*einsum_kg(sys.vA_oooo,t1a,'mnij,bn->mbij') ...
             -einsum_kg(einsum_kg(sys.vA_ooov,t1a,'mnie,ej->mnij'),t1a,'mnij,bn->mbij') ...
             +einsum_kg(einsum_kg(sys.vA_ooov,t1a,'mnje,ei->mnij'),t1a,'mnij,bn->mbij') ...
             +einsum_kg(einsum_kg(sys.vA_ovvv,t1a,'mbef,ei->mbif'),t1a,'mbif,fj->mbij') ...
             -0.5*einsum_kg(einsum_kg(einsum_kg(sys.vA_oovv,t1a,'mnef,ei->mnif'),t1a,'mnif,bn->mbif'),t1a,'mbif,fj->mbij');

chi2A.abej = sys.vA_vvvo ...
             +0.5*einsum_kg(sys.vA_vvvv,t1a,'abef,fj->abej');

% chiB

chi2B.amie_bar = sys.vB_voov ...
                 +einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie') ...
                 -einsum_kg(sys.vB_ooov,t1a,'nmie,an->amie') ...
                 -einsum_kg(einsum_kg(sys.vB_oovv,t1a,'nmfe,an->amfe'),t1a,'amfe,fi->amie') ...
                 +0.5*VCT2B ...
                 +0.5*VBT2A;
             
chi2B.amie = chi2B.amie_bar ...
             +0.5*VCT2B ...
             +0.5*VBT2A;

chi2B.mbej = sys.vB_ovvo ...
             +einsum_kg(sys.vB_ovvv,t1b,'mbef,fj->mbej') ...
             -einsum_kg(sys.vB_oovo,t1b,'mnej,bn->mbej') ...
             -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,fj->mnej'),t1b,'mnej,bn->mbej');
         
chi2B.mnij = sys.vB_oooo ...
             +einsum_kg(sys.vB_oovo,t1a,'mnej,ei->mnij') ...
             +einsum_kg(sys.vB_ooov,t1b,'mnie,ej->mnij') ...
             +einsum_kg(sys.vB_oovv,t2b,'mnef,efij->mnij') ...
             +einsum_kg(einsum_kg(sys.vB_oovv,t1a,'mnef,ei->mnif'),t1b,'mnif,fj->mnij');
         
chi2B.abef = sys.vB_vvvv ...
             -einsum_kg(sys.vB_ovvv,t1a,'mbef,am->abef') ...
             -einsum_kg(sys.vB_vovv,t1b,'amef,bm->abef') ...
             +einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,bn->mbef'),t1a,'mbef,am->abef');

chi2B.mbie = sys.vB_ovov ...
             +einsum_kg(sys.vB_ovvv,t1a,'mbfe,fi->mbie') ...
             -einsum_kg(sys.vB_ooov,t1b,'mnie,bn->mbie') ...
             -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnfe,bn->mbfe'),t1a,'mbfe,fi->mbie') ...
             -einsum_kg(sys.vB_oovv,t2b,'mnfe,fbin->mbie');
         
chi2B.amej = sys.vB_vovo ...
             -einsum_kg(sys.vB_oovo,t1a,'nmej,an->amej') ...
             +einsum_kg(sys.vB_vovv,t1b,'amef,fj->amej') ...
             -einsum_kg(einsum_kg(sys.vB_oovv,t1b,'nmef,fj->nmej'),t1a,'nmej,an->amej');
         
         
chi2B.abej = sys.vB_vvvo ...
             +einsum_kg(sys.vB_vvvv,t1b,'abef,fj->abej') ...
             -einsum_kg(sys.vB_vovo,t1b,'anej,bn->abej') ...
             -einsum_kg(sys.vB_ovvo,t1a,'mbej,am->abej') ...
             +einsum_kg(einsum_kg(sys.vB_oovo,t1b,'mnej,bn->mbej'),t1a,'mbej,am->abej') ...
             -einsum_kg(einsum_kg(sys.vB_ovvv,t1b,'mbef,fj->mbej'),t1a,'mbej,am->abej') ...
             +einsum_kg(einsum_kg(einsum_kg(sys.vB_oovv,t1b,'mnef,bn->mbef'),t1b,'mbef,fj->mbej'),t1a,'mbej,am->abej');
             
chi2B.abie = sys.vB_vvov ...    
             -einsum_kg(sys.vB_ovov,t1a,'mbie,am->abie') ...
             -einsum_kg(sys.vB_voov,t1b,'amie,bm->abie') ...
             +einsum_kg(einsum_kg(sys.vB_ooov,t1a,'mnie,am->anie'),t1b,'anie,bn->abie') ... 
             -einsum_kg(einsum_kg(sys.vB_vovv,t1a,'amfe,fi->amie'),t1b,'amie,bm->abie');

         
chi2B.mbij = sys.vB_ovoo...
             -einsum_kg(sys.vB_oooo,t1b,'mnij,bn->mbij');

% chiC                  
chi2C.bmje = sys.vC_voov ...
             +einsum_kg(sys.vC_vovv,t1b,'bmfe,fj->bmje') ...
             -einsum_kg(sys.vC_oovo,t1b,'mnej,bn->bmje') ...
             -einsum_kg(einsum_kg(sys.vC_oovv,t1b,'mnef,bn->mbef'),t1b,'mbef,fj->bmje');
         



end
