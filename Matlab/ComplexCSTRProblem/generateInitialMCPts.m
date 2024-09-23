function pts = generateInitialMCPts(Z,npts)

G = Z.G;
c = Z.c;
dim = length(G(1,:));

pts = zeros([1,npts]);

for i=1:length(G(1,:))
    vmc = G(:,i)*(2*rand(size(G(:,i),2),npts)-1)+repmat(c,[1,npts])/dim;
    pts = pts + vmc;
end


%figure;
%hold on;
%scatter(pts(1,:),pts(3,:),'Color','b')
%plot(Z,[1,3],'Color','k')
%xlabel('C_a-C_a0')
%ylabel('T_R-T_R0')
%xlim([-0.6,0.6])
%ylim([-5,5])
%hold off;
end