import React from 'react'
//import classNames from 'classnames/bind'
import auth from '../auth'

class ImageFileInput extends React.Component {
    constructor(props)
    {
        super(props);
        this.state = {
            progressbarVisible: false,
            progressbarWidth: 0,
        };
    }

    componentDidMount()
    {
        var _this = this;
        var settings = {
            action: config.apiBasePath + this.props.action,
            allow : "*.(jpg|jpeg|png|gif)",
            headers: {
                "Authorization": "Bearer " + auth.getAccessToken()
            },
            loadstart: function()
            {
                _this.setState({
                    progressbarVisible: true,
                    progressbarWidth: 0,
                });
            },

            progress: function(percent)
            {
                _this.setState({
                    progressbarWidth: Math.ceil(percent),
                });
            },

            allcomplete: function(response, xhr)
            {
                // Show the progress bar for another seconds
                setTimeout(function()
                {
                    _this.setState({
                        progressbarVisible: false,
                        progressbarWidth: 0,
                    });
                }, 1000);

                // Fix error handling
                if(xhr.status == 201)
                {
                    // Save the filename
                    var result = JSON.parse(response);

                    if(_this.props.onFile !== undefined)
                    {
                        _this.props.onFile(result.data);
                    }
                }
                else
                {
                    alert("Upload failed");
                }

            }
        };

        const select = UIkit.uploadSelect($("#upload-select"), settings);
        const drop = UIkit.uploadDrop($("#upload-drop"), settings);
    }

    render()
    {
        return (
            <div>
                <div id="upload-drop" className="uk-placeholder">
                    <div>
                        <i className="uk-icon-cloud-upload uk-icon-medium uk-text-muted uk-margin-small-right"></i>
                        <span>Ladda upp genom att dra och släppa en fil här eller klicka på <a className="uk-form-file">ladda upp<input id="upload-select" type="file"/></a>.</span>
                    </div>

                    {this.state.progressbarVisible ?
                        <div>
                            <div id="progressbar" className="uk-progress">
                                <div className="uk-progress-bar" style={{width: this.state.progressbarWidth + "%"}}>{this.state.progressbarWidth}%</div>
                            </div>
                        </div>
                    : ""}
                </div>
            </div>
        );
    }
}

export default ImageFileInput;