%Document建立用：doc=com.mathworks.xml.XMLUtils.createDocument('名稱')
%Node建立前都要定義： doc.createElement(‘名稱’);
%第一層node附加到Doc後面要用doc.getDocumentElement.appendChild()
%從第二層開始，可以用node.appendChild()
%添加了一個AddressBook的文件，之後向文件中再新增其他的節點。新增的方法是先建立這個節點，然後再append到原來
% ----------------------------------------------------------------------------------
%index = -1;
index=0;
breath_rate = [24 16 20];
docNode=com.mathworks.xml.XMLUtils.createDocument('Data');%檔案
%functions={'24.0234','9.375','16.406'}
%function{index+1}
for index = 0:2 
    functions{index+1} = {num2str(breath_rate)};
    %index = mod(index+1,3); %index=0~2
    entry_node = docNode.createElement('Breathrate'); %第一層node 命名?
   
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
    docNode.getDocumentElement.appendChild(entry_node) %檔案doc_node 接 第一層entry_Node 
  
    xmlwrite('data.xml',docNode);
    type('data.xml');

%%
%{
docNode = com.mathworks.xml.XMLUtils.createDocument('BreathRate');  %產生document 
BreathRate = docNode.getDocumentElement; %檔案node = BreathRate
%BreathRate.setAttribute('version','2.0'); 
product = docNode.createElement('tocitem'); %產生第一層node = tocitem
%product.setAttribute('target','upslope_product_page.html'); 
product.appendChild(docNode.createTextNode('Upslope Area Toolbox'));
BreathRate.appendChild(product) %檔案node 接 第一層node 

product.appendChild(docNode.createComment(' Functions '));
functions = {'demFlow','facetFlow','flowMatrix','pixelFlow'};
for idx = 1:numel(functions)
    curr_node = docNode.createElement('tocitem');
    
    %curr_file = [functions{idx} '_help.html']; 
    %curr_node.setAttribute('target',curr_file);
    
    % Child text is the function name.
    curr_node.appendChild(docNode.createTextNode(functions{idx})); %第二層node放文本
    product.appendChild(curr_node);  %第一層node 接 第二層node
end
xmlwrite('info2.xml',docNode);
type('info2.xml');
%}