function [R, omega, r0, res] = eomccsd(HBar,t1,t2,sys,opts)

    fprintf('\n==================================++Entering EOM-CCSD Routine++=============================\n')
    
    nroot = opts.nroot;

    Nocc = sys.Nocc; Nunocc = sys.Nunocc;
    
    % get Epstein-Nesbet CCSD HBar diagonal
    %[D, ~, ~] = HBar_CCSD_SD_diagonal(HBar,t1,t2,sys);

%    < phi_{ia} | HBar | phi_{ia} >
%   < phi_{ijab} | HBar | phi_{ijab} >

    Dai = zeros(Nunocc,Nocc);
    Dabij = zeros(Nunocc,Nunocc,Nocc,Nocc);

    for a = 1:Nunocc
        for i = 1:Nocc
            [D1,D2,D3] = HBar_CCSD_S_diagonal(a,i,HBar);
            Dai(a,i) = D1;
            for b = 1:Nunocc
                for j = 1:Nocc
                    [D1,D2,D3] = HBar_CCSD_D_diagonal(a,b,i,j,HBar);
                    Dabij(a,b,i,j) = D1;
                end
            end
        end
    end

    D = cat(1, Dai(:), Dabij(:));

%     
    % Matrix-vector product function
    HRmat = @(x) HR_matmat(x,HBar);

    % use CIS guess as initial basis vectors
    if strcmp(opts.init_guess,'cis')
        [omega, B_cis] = get_cis_guess(sys,nroot,opts.nvec_per_root);
        fprintf('Initial CIS energies:\n')
        for i = 1:length(omega)
            fprintf('      E%d = %4.8f\n',i,omega(i))
        end
        B0 = cat(1,B_cis,zeros(sys.Nocc^2*sys.Nunocc^2,size(B_cis,2)));
        opts.init_guess = 'custom';
        
    % use diagonal basis vector guess (identity)
    else
        B0 = [];
        opts.init_guess = 'diagonal';
    end

    %[ R, L_R, omega, res, it, flag_conv] = davidson_fcn(HRmat, D, HBar_dim, nroot, B0, 'right', opts);
    %[R, omega, res, flag_conv] = davidson(HRmat,D,nroot,B0,opts);
    [R, omega, res, flag_conv] = davidson_update_R(HRmat,Dai,Dabij,nroot,B0,opts);

    omega = real(omega);
    
    % calculate r0 for each excited state
    r0 = zeros(nroot,1);
    for i = 1:nroot
        r1 = reshape(R(sys.posv1,i),[Nunocc,Nocc]);
        r2 = reshape(R(sys.posv2,i),[Nunocc,Nunocc,Nocc,Nocc]);
        r0(i) = 1/omega(i)*(einsum_kg(HBar{1}{1,2},r1,'ia,ai->') +...
                            0.25*einsum_kg(HBar{2}{1,1,2,2},r2,'ijab,abij->'));
    end
end

