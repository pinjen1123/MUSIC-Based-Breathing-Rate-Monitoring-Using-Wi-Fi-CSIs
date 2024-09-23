function datatoxml(data)
    %Path='C:\Users\User\Desktop\linux-80211n-csitool-supplementary'
    docNode=com.mathworks.xml.XMLUtils.createDocument('Data');
    entry_node = docNode.createElement('Breathrate'); %第一層node 命名?
    index_node = docNode.createElement('index_0'); %第二層node 命名?
    index_node.appendChild(docNode.createTextNode(num2str(data)));
    entry_node.appendChild(index_node)
    docNode.getDocumentElement.appendChild(entry_node) %檔案doc_node 接 第一層entry_Node 
    
    str = ['C:\Users\User\Desktop\linux-80211n-csitool-supplementary\data.xml'];
    xmlwrite(str,docNode);
    %type('data.xml');
end