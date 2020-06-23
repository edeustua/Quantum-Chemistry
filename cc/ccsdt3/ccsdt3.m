function [t1,t2,t3,Ecorr] = ccsdt3(sys,opts)

    diis_size = opts.diis_size;
    maxit = opts.maxit;
    tol = opts.tol;
    
    tic_Start = tic;
    
    fprintf('\n==================================++Entering CCSDT Routine++================================\n')
    
    % Initialize T1 and T2 DIIS containers
    T = zeros(sys.triples3_dim,1);
    T_list = zeros(sys.triples3_dim,diis_size);
    T_resid_list = zeros(sys.triples3_dim,diis_size);
    
    Nact_h = sys.Nact_h; Nact_p = sys.Nact_p;
    Nunocc = sys.Nunocc; Nocc = sys.Nocc;
    
    size_t1 = [Nunocc,Nocc];
    size_t2 = [Nunocc,Nunocc,Nocc,Nocc];
    size_t3 = [Nact_p,Nact_p,Nact_p,Nact_h,Nact_h,Nact_h];
    
    % Jacobi/DIIS iterations
    it = 1; flag_conv = 0;
    while it < maxit
        
        tic
        
        % store old T and get current diis dimensions
        T_old = T;
        
        % extract current T
        t1 = reshape(T(sys.posv1),size_t1);
        t2 = reshape(T(sys.posv2),size_t2);
        t3 = reshape(T(sys.posv3_act),size_t3);
        
        % CC correlation energy
        Ecorr = cc_energy(t1,t2,sys);

        % update t1, t2, and t3 sequentially
        t1 = update_t1_ccsdt3(t1,t2,t3,sys);
        t2 = update_t2_ccsdt3(t1,t2,t3,sys);
        t3 = update_t3_ccsdt3(t1,t2,t3,sys);
        
        % store vectorized results
        T(sys.posv1) = t1(:); T(sys.posv2) = t2(:); T(sys.posv3_act) = t3(:);
        
        % print largest T3 amplitudes
%         nprint = 10;
%         [~, idx] = maxk(abs(t3(:)),36*nprint);
%         fprintf('\nLargest T3 amplitudes are:\n')
%         for i = 1:36:length(idx)
%             [ia,ib,ic,ii,ij,ik] = ind2sub(size_t3,idx(i));
%             fprintf('t3(%d,%d,%d,%d,%d,%d) = %4.8f\n',ia,ib,ic,ii,ij,ik,t3(idx(i)))
%         end

        % build DIIS residual
        T_resid = T - T_old;
        
        % check for exit condition
        ccsdt_resid = sqrt(mean(T_resid.^2));
        if ccsdt_resid < tol
            flag_conv = 1;
            break;
        end
        
        % append trial and residual vectors to lists
        T_list(:,mod(it,diis_size)+1) = T;
        T_resid_list(:,mod(it,diis_size)+1) = T_resid;
         
        % diis extrapolate
        if it >= diis_size
           T = diis_xtrap(T_list,T_resid_list);
        end


        fprintf('\nIter-%d     Residuum = %4.12f      Ecorr = %4.12f      Elapsed Time = %4.2f s',it,ccsdt_resid,Ecorr,toc);
        
        it = it + 1;
        
    end
    
    % return final T amplitudes and correlation energy
    t1 = reshape(T(sys.posv1),size_t1);
    t2 = reshape(T(sys.posv2),size_t2);
    t3 = reshape(T(sys.posv3_act),size_t3);
    Ecorr = cc_energy(t1,t2,sys);
    
    if flag_conv == 1
        fprintf('\nCCSDT-3 successfully converged in %d iterations (%4.2f seconds)\n',it,toc(tic_Start));
        fprintf('Final Correlation Energy = %4.12f Ha\n',Ecorr);
    else
        fprintf('\nCCSDT-3 failed to converged in %d iterations\n',maxit)
    end
            
        

end


       