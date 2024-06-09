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
%plot(Z,[1,2])
%scatter(pts(1,:),pts(2,:))
%xlabel('C-C_0');
%ylabel('T-T_0');
%legend();
%hold off;
end
