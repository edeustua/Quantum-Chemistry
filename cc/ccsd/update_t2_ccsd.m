function [t2] = update_t2_ccsd(t1,t2,sys)

    % Intermediates
    
    chi_mi = sys.foo_masked + ...
             einsum_kg(sys.Vooov,t1,'mnif,fn->mi') + ...
             0.5*einsum_kg(sys.Voovv,t2,'mnef,efin->mi');
    
    chi_me = sys.fov + einsum_kg(sys.Voovv,t1,'mnef,fn->me');
    
    chi_ae = sys.fvv_masked + ...
             einsum_kg(sys.Vvovv,t1,'anef,fn->ae') - ...
             0.5*einsum_kg(sys.Voovv,t2,'mnef,afmn->ae') - ...
             einsum_kg(chi_me,t1,'me,am->ae');
    
    chit_mi = chi_mi + einsum_kg(chi_me,t1,'me,ei->mi');
    
    chit_anef = sys.Vvovv - 0.5*einsum_kg(sys.Voovv,t1,'mnef,am->anef');
    
    chi_anej = sys.Vvovo - ... 
               0.5*einsum_kg(sys.Voovo,t1,'mnej,am->anej') + ...
               0.5*einsum_kg(chit_anef,t1,'anef,fj->anej');
    
    chi_mnif = sys.Vooov + 0.5*einsum_kg(sys.Voovv,t1,'mnef,ei->mnif');
    
    chi_mbij =  sys.Vovoo - ...
                0.5*einsum_kg(sys.Voooo,t1,'mnij,bn->mbij') - ...
                0.5*einsum_kg(chit_anef,t2,'bmef,efij->mbij');
    
    chi_abej = 0.5*sys.Vvvvo - einsum_kg(chi_anej,t1,'anej,bn->abej');
    
    chi_mnij = 0.5*sys.Voooo + ...
               0.25*einsum_kg(sys.Voovv,t2,'mnef,efij->mnij') + ...
               einsum_kg(chi_mnif,t1,'mnif,fj->mnij');
    
    chi_anef = chit_anef - 0.5*einsum_kg(sys.Voovv,t1,'mnef,am->anef');
    
    chit_anej = sys.Vvovo - ... 
                einsum_kg(sys.Voovo,t1,'mnej,am->anej') - ...
                0.5*einsum_kg(sys.Voovv,t2,'mnef,afmj->anej') + ...
                einsum_kg(chi_anef,t1,'anef,fj->anej');
    
    chi_efij = einsum_kg(t1,t1,'ei,fj->efij') + 0.5*t2;

    
    % build T2

    % standard order
    TEMP2_abij = einsum_kg(chi_abej,t1,'abej,ei->abij') - ...
            einsum_kg(chit_anej,t2,'anej,ebin->abij') - ...
            0.5*einsum_kg(chi_mbij,t1,'mbij,am->abij') + ...
            0.5*einsum_kg(chi_ae,t2,'ae,ebij->abij') - ...
            0.5*einsum_kg(chit_mi,t2,'mi,abmj->abij') + ...
            0.25*einsum_kg(chi_mnij,t2,'mnij,abmn->abij') + ...
            0.25*einsum_kg(sys.Vvvvv,chi_efij,'abef,efij->abij');
    % (ij)    
    TEMP2_abji = einsum_kg(chi_abej,t1,'abei,ej->abij') - ...
            einsum_kg(chit_anej,t2,'anei,ebjn->abij') - ...
            0.5*einsum_kg(chi_mbij,t1,'mbji,am->abij') + ...
            0.5*einsum_kg(chi_ae,t2,'ae,ebji->abij') - ...
            0.5*einsum_kg(chit_mi,t2,'mj,abmi->abij') + ...
            0.25*einsum_kg(chi_mnij,t2,'mnji,abmn->abij') + ...
            0.25*einsum_kg(sys.Vvvvv,chi_efij,'abef,efji->abij');
    % (ab)    
    TEMP2_baij = einsum_kg(chi_abej,t1,'baej,ei->abij') - ...
            einsum_kg(chit_anej,t2,'bnej,eain->abij') - ...
            0.5*einsum_kg(chi_mbij,t1,'maij,bm->abij') + ...
            0.5*einsum_kg(chi_ae,t2,'be,eaij->abij') - ...
            0.5*einsum_kg(chit_mi,t2,'mi,bamj->abij') + ...
            0.25*einsum_kg(chi_mnij,t2,'mnij,bamn->abij') + ...
            0.25*einsum_kg(sys.Vvvvv,chi_efij,'baef,efij->abij');
    
    % (ab)(ij)    
    TEMP2_baji = einsum_kg(chi_abej,t1,'baei,ej->abij') - ...
            einsum_kg(chit_anej,t2,'bnei,eajn->abij') - ...
            0.5*einsum_kg(chi_mbij,t1,'maji,bm->abij') + ...
            0.5*einsum_kg(chi_ae,t2,'be,eaji->abij') - ...
            0.5*einsum_kg(chit_mi,t2,'mj,bami->abij') + ...
            0.25*einsum_kg(chi_mnij,t2,'mnji,bamn->abij') + ...
            0.25*einsum_kg(sys.Vvvvv,chi_efij,'baef,efji->abij');
          
    X_abij = sys.Vvvoo + TEMP2_abij - TEMP2_abji - TEMP2_baij + TEMP2_baji;
    
    for a = 1:sys.Nunocc
        for b = a+1:sys.Nunocc
            for i = 1:sys.Nocc
                for j = i+1:sys.Nocc
                    t2(a,b,i,j) = X_abij(a,b,i,j)/...
                                  (sys.foo(i,i)+sys.foo(j,j)-sys.fvv(a,a)-sys.fvv(b,b));
                              
                    t2(a,b,j,i) = -t2(a,b,i,j);
                    t2(b,a,i,j) = -t2(a,b,i,j);
                    t2(b,a,j,i) = t2(a,b,i,j);
                end
            end
        end
    end
    
end



