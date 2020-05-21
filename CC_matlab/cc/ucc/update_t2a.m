function [t2a] = update_t2a(t1a, t1b, t2a, t2b, t2c, chi1A, chi1B, chi2A, chi2B, chi2C, sys)

    X2a_abij = sys.vA_vvoo...
               +einsum(chi1A.ae,t2a,'ae,ebij->abij')...
               -einsum(einsum(chi1A.me,t1a,'me,am->ae'),t2a,'ae,ebij->abij')... % add
               -einsum(chi1A.ae,t2a,'be,eaij->abij')...
               +einsum(einsum(chi1A.me,t1a,'me,bm->be'),t2a,'be,eaij->abij')... % add
               -einsum(chi1A.mi,t2a,'mi,abmj->abij')...
               -einsum(einsum(chi1A.me,t1a,'me,ei->mi'),t2a,'mi,abmj->abij')... % add
               +einsum(chi1A.mi,t2a,'mj,abmi->abij')...
               +einsum(einsum(chi1A.me,t1a,'me,ej->mj'),t2a,'mj,abmi->abij')... % add
               +einsum(chi2A.amie_bar,t2a,'amie,ebmj->abij')...
               -einsum(chi2A.amie_bar,t2a,'amje,ebmi->abij')...
               -einsum(chi2A.amie_bar,t2a,'bmie,eamj->abij')...
               +einsum(chi2A.amie_bar,t2a,'bmje,eami->abij')...
               +einsum(chi2B.amie_bar,t2b,'amie,bejm->abij')...
               -einsum(chi2B.amie_bar,t2b,'amje,beim->abij')...
               -einsum(chi2B.amie_bar,t2b,'bmie,aejm->abij')...
               +einsum(chi2B.amie_bar,t2b,'bmje,aeim->abij')...
               +0.5*einsum(chi2A.mnij,t2a,'mnij,abmn->abij')...
               +0.5*einsum(chi2A.abef,t2a,'abef,efij->abij')...
               -einsum(chi2A.mbij,t1a,'mbij,am->abij')...
               +einsum(chi2A.mbij,t1a,'maij,bm->abij')...
               +einsum(chi2A.abej,t1a,'abej,ei->abij')...
               -einsum(chi2A.abej,t1a,'abei,ej->abij');
    
    omega = 1;
    for a = 1:sys.Nvir_alpha
        for b = a+1:sys.Nvir_alpha
            for i = 1:sys.Nocc_alpha
                for j = i+1:sys.Nocc_alpha
                    temp = X2a_abij(a,b,i,j)/...
                                       (sys.fa_oo(i,i)+sys.fa_oo(j,j)-sys.fa_vv(a,a)-sys.fa_vv(b,b));
                    t2a(a,b,i,j) = (1-omega)*t2a(a,b,i,j) + omega*temp;                
                    t2a(b,a,i,j) = -t2a(a,b,i,j);
                    t2a(a,b,j,i) = -t2a(a,b,i,j);
                    t2a(b,a,j,i) = t2a(a,b,i,j);
                end
            end
        end
    end


end
