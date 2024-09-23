%Document�إߥΡGdoc=com.mathworks.xml.XMLUtils.createDocument('�W��')
%Node�إ߫e���n�w�q�G doc.createElement(���W�١�);
%�Ĥ@�hnode���[��Doc�᭱�n��doc.getDocumentElement.appendChild()
%�q�ĤG�h�}�l�A�i�H��node.appendChild()
%�K�[�F�@��AddressBook�����A����V��󤤦A�s�W��L���`�I�C�s�W����k�O���إ߳o�Ӹ`�I�A�M��Aappend����
% ----------------------------------------------------------------------------------
%index = -1;
index=0;
breath_rate = [24 16 20];
docNode=com.mathworks.xml.XMLUtils.createDocument('Data');%�ɮ�
%functions={'24.0234','9.375','16.406'}
%function{index+1}
for index = 0:2 
    functions{index+1} = {num2str(breath_rate)};
    %index = mod(index+1,3); %index=0~2
    entry_node = docNode.createElement('Breathrate'); %�Ĥ@�hnode �R�W?
   
    index0_node = docNode.createElement('index_0');
    index1_node = docNode.createElement('index_1');
    index2_node = docNode.createElement('index_2');
    
    if index > -1
        index0_node.appendChild(docNode.createTextNode(functions{1}));
    end
    if index > 0 
        index1_node.appendChild(docNode.createTextNode(functions{2}));
    end
    if index > 1 
        index2_node.appendChild(docNode.createTextNode(functions{3}));
    end
    entry_node.appendChild(index0_node);
    entry_node.appendChild(index1_node);
    entry_node.appendChild(index2_node);
    index=index+1;
end
    docNode.getDocumentElement.appendChild(entry_node) %�ɮ�doc_node �� �Ĥ@�hentry_Node 
  
    xmlwrite('data.xml',docNode);
    type('data.xml');

%%
%{
docNode = com.mathworks.xml.XMLUtils.createDocument('BreathRate');  %����document 
BreathRate = docNode.getDocumentElement; %�ɮ�node = BreathRate
%BreathRate.setAttribute('version','2.0'); 
product = docNode.createElement('tocitem'); %���ͲĤ@�hnode = tocitem
%product.setAttribute('target','upslope_product_page.html'); 
product.appendChild(docNode.createTextNode('Upslope Area Toolbox'));
BreathRate.appendChild(product) %�ɮ�node �� �Ĥ@�hnode 

product.appendChild(docNode.createComment(' Functions '));
functions = {'demFlow','facetFlow','flowMatrix','pixelFlow'};
for idx = 1:numel(functions)
    curr_node = docNode.createElement('tocitem');
    
    %curr_file = [functions{idx} '_help.html']; 
    %curr_node.setAttribute('target',curr_file);
    
    % Child text is the function name.
    curr_node.appendChild(docNode.createTextNode(functions{idx})); %�ĤG�hnode��奻
    product.appendChild(curr_node);  %�Ĥ@�hnode �� �ĤG�hnode
end
xmlwrite('info2.xml',docNode);
type('info2.xml');
%}