function datatoxml(data)
    %Path='C:\Users\User\Desktop\linux-80211n-csitool-supplementary'
    docNode=com.mathworks.xml.XMLUtils.createDocument('Data');
    entry_node = docNode.createElement('Breathrate'); %�Ĥ@�hnode �R�W?
    index_node = docNode.createElement('index_0'); %�ĤG�hnode �R�W?
    index_node.appendChild(docNode.createTextNode(num2str(data)));
    entry_node.appendChild(index_node)
    docNode.getDocumentElement.appendChild(entry_node) %�ɮ�doc_node �� �Ĥ@�hentry_Node 
    
    str = ['C:\Users\User\Desktop\linux-80211n-csitool-supplementary\data.xml'];
    xmlwrite(str,docNode);
    %type('data.xml');
end