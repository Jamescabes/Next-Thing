import React from 'react';

class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }

    componentDidCatch(error, errorInfo) {
        console.error('ErrorBoundary caught:', error, errorInfo);
    }

    handleRetry = () => {
        this.setState({ hasError: false, error: null });
    };

    render() {
        if (this.state.hasError) {
            return (
                <div style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    minHeight: '100vh',
                    padding: '24px',
                    textAlign: 'center',
                    fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, sans-serif'
                }}>
                    <div style={{ fontSize: '48px', marginBottom: '16px' }}>
                        :(
                    </div>
                    <h1 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '8px' }}>
                        Something went wrong
                    </h1>
                    <p style={{ fontSize: '14px', color: '#666', marginBottom: '24px', maxWidth: '300px' }}>
                        The app ran into an unexpected error. Please try again.
                    </p>
                    <button
                        onClick={this.handleRetry}
                        style={{
                            padding: '12px 24px',
                            fontSize: '16px',
                            fontWeight: 600,
                            background: '#000',
                            color: '#fff',
                            border: 'none',
                            borderRadius: '12px',
                            cursor: 'pointer'
                        }}
                    >
                        Try Again
                    </button>
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
