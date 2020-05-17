function [Ecorr] = ucc_energy(t1a,t1b,t2a,t2b,t2c,sys)



    Ecorr = einsum(sys.fa_ov,t1a,'me,em->')+...
            einsum(sys.fb_ov,t1b,'me,em->')+...
            0.25*einsum(sys.vA_oovv,t2a,'mnef,efmn->')+...
            0.25*einsum(sys.vC_oovv,t2c,'mnef,efmn->')+...
            einsum(sys.vB_oovv,t2b,'mnef,efmn->')+...
            0.5*einsum(einsum(sys.vA_oovv,t1a,'mnef,fn->me'),t1a,'me,em->')+...
            0.5*einsum(einsum(sys.vC_oovv,t1b,'mnef,fn->me'),t1b,'me,em->')+...
            einsum(einsum(sys.vB_oovv,t1a,'mnef,em->nf'),t1b,'nf,fn->');

%     t1 = convert_spinint_to_spinorb({t1a,t1b},sys);
%     t2 = convert_spinint_to_spinorb({t2a,t2b,t2c},sys);
%     Ecorr = cc_energy(t1,t2,sys.VM,sys.FM,sys.iocc,sys.ivir);
end

