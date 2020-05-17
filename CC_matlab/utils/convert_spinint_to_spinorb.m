function [T_out] = convert_spinint_to_spinorb(T, sys)

    Nocc = sys.Nocc_alpha + sys.Nocc_beta;
    Nvir = sys.Nvir_alpha + sys.Nvir_beta;
    
    iocc_alpha = sys.iocc_alpha;
    iocc_beta = sys.iocc_beta;
    
    ivir_beta = sys.ivir_beta - Nocc;
    ivir_alpha = sys.ivir_alpha - Nocc;
    
    if length(T) == 2 % t1a, t1b
        
        t1a = T{1};
        t1b = T{2};
        T_out = zeros(Nvir,Nocc);
        T_out(ivir_alpha,iocc_alpha) = t1a;
        T_out(ivir_beta,iocc_beta) = t1b;
        
    elseif length(T) == 3 % t2a, t2b, t2c
        
        t2a = T{1}; t2b = T{2}; t2c = T{3};
        T_out = zeros(Nvir,Nvir,Nocc,Nocc);
        
        T_out(ivir_alpha,ivir_alpha,iocc_alpha,iocc_alpha) = t2a;
        
        T_out(ivir_alpha,ivir_beta,iocc_alpha,iocc_beta) = t2b;
        T_out(ivir_beta,ivir_alpha,iocc_beta,iocc_alpha) = permute(t2b,[2,1,4,3]);
        T_out(ivir_alpha,ivir_beta,iocc_beta,iocc_alpha) = permute(-t2b,[1,2,4,3]);
        T_out(ivir_beta,ivir_alpha,iocc_alpha,iocc_beta) = permute(-t2b,[2,1,3,4]);

        
        T_out(ivir_beta,ivir_beta,iocc_beta,iocc_beta) = t2c;
       
    else
        disp('Size of T is not supported!')
    end
        


end

