function [t1a] = update_t1a_ccsdt3(t1a, t1b, t2a, t2b, t2c, t3a, t3b, t3c, t3d, chi1A, chi1B, chi2A, chi2B, chi2C, sys, shift)

    % CCSD part
    X1a_ai = sys.fa_vo +... % 1
             +einsum_kg(chi1A.ae_bar,t1a,'ae,ei->ai')... % 8
             -einsum_kg(chi1A.mi_bar,t1a,'mi,am->ai')... % 8 (effectively 5... 3 in common between chi.ae and chi.mi)
             +einsum_kg(chi1A.me,t2a,'me,aeim->ai') ... % 3
             +einsum_kg(chi1B.me,t2b,'me,aeim->ai') ... % 3
             +0.5*einsum_kg(sys.vA_vovv,t2a,'amef,efim->ai')... % 1
             -0.5*einsum_kg(sys.vA_ooov,t2a,'mnie,aemn->ai')... % 1
             +einsum_kg(sys.vB_vovv,t2b,'amef,efim->ai')... % 1
             -einsum_kg(sys.vB_ooov,t2b,'mnie,aemn->ai')... % 1
             +einsum_kg(sys.vA_voov,t1a,'amie,em->ai')... % 1
             +einsum_kg(sys.vB_voov,t1b,'amie,em->ai'); % 1

    % CCSDT part
    TEMP3 =  +0.25*einsum_kg(sys.vA_HHPP,t3a,'mnef,aefimn->ai')...
             +einsum_kg(sys.vB_HHPP,t3b,'mnef,aefimn->ai')...
             +0.25*einsum_kg(sys.vC_HHPP,t3c,'mnef,aefimn->ai');
            
         
    omega = 1;          
    for i = 1:sys.Nocc_alpha
        for a = 1:sys.Nvir_alpha
%             if a <= sys.Nact_p && i - sys.Ncore > 0
%                 t1(a,i) = (X_ai(a,i)+TEMP1_3(a,i-sys.Ncore))/(sys.foo(i,i)-sys.fvv(a,a));
%             else
%                 t1(a,i) = X_ai(a,i)/(sys.foo(i,i)-sys.fvv(a,a));
%             end
            temp = X1a_ai(a,i)/(sys.fa_oo(i,i) - sys.fa_vv(a,a) - shift);
            t1a(a,i) = (1-omega)*t1a(a,i) + omega*temp;
        end
    end
             
         
end