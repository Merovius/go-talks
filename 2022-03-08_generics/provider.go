package provider

import (       // OMIT
	"context"  // OMIT
	"provider" // OMIT
	"reflect"  // OMIT
)              // OMIT
               // OMIT
type ID string

type Provider interface {
	ID() ID
	Run(ctx context.Context, pub Publisher, req Message) error
	RequestType() reflect.Type
	ResponseType() reflect.Type
	Close() error
}

type Publisher interface{ Publish(Message) }

func Call(ctx context.Context, p ID, req Message) (Message, error)

func Stream(ctx context.Context, p ID, req Message) ResponseIterator
