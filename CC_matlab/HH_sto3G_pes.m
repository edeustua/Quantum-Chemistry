clear all
clc
close all

scfopts.diis_size = 3; 
scfopts.maxit = 200; 
scfopts.tol = 1e-8;
scfopts.level_shift = 0.0; 

atoms = {'H','H'};

atom_valency = [1, 1];

Nelec = sum(atom_valency);
Nocc = Nelec/2;

HH_dist = linspace(1,6,50);

num_pts = length(HH_dist);

ENERGY_RHF = zeros(1,num_pts);
dE_RHF = zeros(1,3,num_pts);
dE_RHF_numerical = zeros(1,num_pts-1);

for JJ = 1:num_pts

        fprintf('\nGEOMETRY %d (OUT OF %d) - \n',JJ,num_pts)

        atom_coordinates = [0, 0, -HH_dist(JJ)/2;
                            0, 0,  HH_dist(JJ)/2];

        % get basis set
        basis = get_basis_631G(atoms, atom_coordinates);
        Norb = length(basis);

        % calculate AO integrals
        Vnuc = calc_nuclear_nuclear(atom_coordinates,atom_valency);
        Smat = get_Smat(basis); 
        Zmat = get_Zmat(basis,atom_coordinates,atom_valency); 
        [VVmat_chemist] = get_ERImat(basis,0.0);

        % SCF solver
        sys_scf.e1int = Zmat; sys_scf.overlap = Smat; 
        sys_scf.e2int = permute(VVmat_chemist,[1,3,2,4]);
        sys_scf.Vnuc = Vnuc; sys_scf.Nelec = Nelec; 
        if JJ == 1
            [Escf, C, P, eps_mo, Fock] = rhf(sys_scf,scfopts);
        else
            [Escf, C, P, eps_mo, Fock] = rhf(sys_scf,scfopts,P);
        end

        % record ground state
        ENERGY_RHF(JJ) = Escf;

        % calculate derivative AO integrals
        %grad_coords = atom_coordinates(2,:);
        dSmat = get_dSmat(basis,atom_coordinates);
        dZmat = get_dZmat(basis,atom_coordinates,atom_valency,atom_coordinates);
        tic
        dVVmat = get_dERImat(basis,atom_coordinates);
        toc
        dVnn = grad_nuclear_nuclear(atom_coordinates,atom_valency,atom_coordinates);
        
% SPINORBITAL ANALYTICAL DETIVATIVE        
%         C = spatial_to_spinorb(C);
%         P = einsum_kg(C(:,1:Nelec),C(:,1:Nelec),'pi,qi->pq');
%         
%         W = zeros(size(P));
%         eps_mo = [eps_mo'; eps_mo']; eps_mo = eps_mo(:);
%         for p = 1:size(P,1)
%             for q = 1:size(P,2)
%                 for i = 1:Nelec
%                     W(p,q) = W(p,q) + eps_mo(i)*C(p,i)*C(q,i);
%                 end
%             end
%         end
%         
%         % calculating RHF energy derivative
%         for M = 1:size(grad_coords,1)
%             dZ = dZmat{M}; dS = dSmat{M}; dERI = dVVmat{M}; dVnuc = dVnn{M};
%             for j = 1:3
%                 dZj = spatial_to_spinorb(squeeze(dZ(:,:,j)));
%                 dSj = spatial_to_spinorb(squeeze(dS(:,:,j)));
%                 dERIj = spatial_to_spinorb(permute(squeeze(dERI(:,:,:,:,j)),[1,3,2,4]));                
%                 dERIj_asym = dERIj - permute(dERIj,[1,2,4,3]);
%                 
%                 dE_RHF(M,j,JJ) = einsum_kg(P,dZj,'uv,uv->') ...
%                                 +0.5*einsum_kg(einsum_kg(P,dERIj_asym,'ls,ulvs->uv'),P,'uv,uv->')...
%                                 -einsum_kg(W,dSj,'uv,uv->') + dVnuc(j);            
%             end
%         end
                
        % energy-weighted density matrix
        W = 2*einsum_kg(C(:,1:Nocc)*diag(eps_mo(1:Nocc)),C(:,1:Nocc),'pi,qi->pq');
        
        % calcualte analytical gradient
        for M = 1:size(atom_coordinates,1)
            dZ = dZmat{M}; dS = dSmat{M}; dERI = dVVmat{M}; dVnuc = dVnn{M};
            for j = 1:3
                dZj = squeeze(dZ(:,:,j)); dSj = squeeze(dS(:,:,j)); dERIj = squeeze(dERI(:,:,:,:,j));
                dERIj_asym = dERIj - 0.5*permute(dERIj,[1,4,3,2]);
                dE_RHF(M,j,JJ) = einsum_kg(P,dZj,'uv,uv->')...
                                 +0.5*einsum_kg(einsum_kg(P,dERIj_asym,'ls,uvls->uv'),P,'uv,uv->')...
                                 -einsum_kg(W,dSj,'uv,uv->')...
                                 +dVnuc(j);      
            end
        end
        
        if JJ > 1
            dE_RHF_numerical(JJ-1) = (ENERGY_RHF(JJ)-ENERGY_RHF(JJ-1))/abs(HH_dist(2)-HH_dist(1));
            
            fprintf('\nR = %4.4f\n',HH_dist(JJ))
            fprintf('Numerical = %4.12f\n',dE_RHF_numerical(JJ-1))
            fprintf('Analytical = %4.12f\n',dE_RHF(1,3,JJ))
        end        
                  
        % ao to mo transformation
        e1int = ao_to_mo(sys_scf.e1int,C);
        e2int = ao_to_mo(sys_scf.e2int,C);

        % build up CC system
        nfzc = 0; Nocc_a = Nelec/2; Nocc_b = Nelec/2;
        sys = build_system_ucc(e1int,e2int,Vnuc,Nocc_a,Nocc_b,nfzc);

        % UCCSD
        if JJ == 1 % use 0 T vectors as guess
            [cc_t,Ecorr_ccsd] = uccsd(sys,ccopts);
        else % use previous cluster amplitudes as guess
            [cc_t,Ecorr_ccsd] = uccsd(sys,ccopts,T_init);
        end
        T_init = cat(1,cc_t.t1a(:),cc_t.t1b(:),cc_t.t2a(:),cc_t.t2b(:),cc_t.t2c(:));

end


%%

dE_RHF_plot = 0.5*(squeeze(dE_RHF(2,3,1:JJ)) - squeeze(dE_RHF(1,3,1:JJ)));

figure(1)
yyaxis left
plot(HH_dist(1:JJ),ENERGY_RHF(1:JJ),'bo','MarkerSize',4,'MarkerFaceColor',[0,0,1])
hold on
plot(HH_dist(1:JJ),ENERGY_RHF(1:JJ),'b-.')
hold off
ylabel('HF Energy [E_h]')
yyaxis right
plot(HH_dist(1:JJ),dE_RHF_plot,HH_dist(2:JJ),dE_RHF_numerical(1:JJ-1))
xlabel('H-H Distance [a.u.]')
ylabel('HF energy derivative [E_h/a.u.]')
grid on
set(gca,'FontSize',14,'Linewidth',2,'Box','off')


