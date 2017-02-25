// tutorial8.js

var data = [
    {id: 1, author: "Pete Hunt", text: "This is one comment"},
    {id: 2, author: "Jordan Walke", text: "This is *another* comment"}
];

var Comment = React.createClass({
    rawMarkup:function () {
        var md = new Remarkable();
        var rawMarkup = md.render(this.props.children.toString());
        return {__html: rawMarkup};
    }
    ,
    render:function () {
        return (
            <div className="comment">
                <h2 className="commentAuthor">
                    {this.props.author}
                </h2>
                <span dangerouslySetInnerHTML={this.rawMarkup()}></span>
            </div>
        );
    }
});
var CommentBox = React.createClass({

    loadCommentsFromServer:function () {
        $.ajax({
            url:this.props.url,
            dataType:'json',
            cahe:false,
            success:function (data) {
               // console.log(data);
                this.setState({data:data});
            }.bind(this),
            error:function (xhr,status,err) {
                console.error(this.props.url,status,err.toString());
            }.bind(this)
        });
    },
    componentDidMount:function () {
        console.log('componentDidMount');
        this.loadCommentsFromServer();
       // setInterval(this.loadCommentsFromServer,this.props.pollInterval);
    },
    handleCommentSubmit:function (comment) {
        var comments = this.state.data;
        comment.id = Date.now();
        var newComments = comments.concat(comment);
        this.setState({data: newComments});
           $.ajax({
               url:this.props.url,
               dataType:'json',
               type:'POST',
               data:comment,
               success:function (data) {
                   this.setState({data:data});
               }.bind(this),
               error:function (xhr,status,err) {
                   this.setState({data: comments});
                   console.error(this.props.url,status,err.toString());
               }.bind(this)
           });

    },
    getInitialState:function () {
        console.log("InitialState");
        return {data:[]};
    },
    render: function() {
        console.log("render:" + this.state.data);
        return (
            <div className="commentBox">
                <h1>Comments</h1>
                <CommentList data={this.state.data}/>
                <CommentForm onCommentSubmit={this.handleCommentSubmit}/>
            </div>
        );
    }
});

var CommentList = React.createClass({
    render: function () {
        //console.log(this.props.data[0]);
        //var data = "[" + '<%=this.props.data%>' + "]";
        console.log("the length of data is :"+data.length);
        var commentNodes = this.props.data.map(function(comment){
            //console.log(comment);
           return(
               <Comment author={comment.author} key={comment.id}>
                   {comment.text}
               </Comment>
           );
        });
        return(
            <div className="commentList">
                {commentNodes}
            </div>
        );
    }
});

var CommentForm = React.createClass({
    getInitialState:function () {
        return {author:'',text:''};
    },
    handleAuthorChange:function(e){
      this.setState({author: e.target.value});
    },
    handleTextChange:function (e) {
    this.setState({text: e.target.value});
    },
    handleSubmit:function (e) {
      e.preventDefault();
      var  author = this.state.author.trim();
      var text = this.state.text.trim();
      if (!text || !author)
      {
          return;
      }
      this.props.onCommentSubmit({author: author,text:text});
      this.setState({author:'',text:''});
    },

    render:function () {
        return(

            <form className="commentForm" onSubmit={this.handleSubmit}>
            <input type="text"
                   placeholder="Your name"
                   value={this.state.author}
            onChange={this.handleAuthorChange}/>
                <input type="text"
                       placeholder="Say something..."
                       value={this.state.text}
                onChange={this.handleTextChange}/>
                <input type="submit" value="Post"/>
            </form>
        );
    }
});


ReactDOM.render(
    <CommentBox url="http://localhost:2000/api/comments" pollInterval={2000}/>,
    document.getElementById('content')
);


