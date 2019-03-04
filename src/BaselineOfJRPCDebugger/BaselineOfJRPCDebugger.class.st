Class {
	#name : #BaselineOfJRPCDebugger,
	#superclass : #BaselineOf,
	#category : #BaselineOfJRPCDebugger
}

{ #category : #baselines }
BaselineOfJRPCDebugger >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			"Packages"
			spec
				package: 'JRPCDebugger' with: [ spec requires: #('JRPC') ].
			spec baseline: 'JRPC' with: [ 
				spec
					repository: 'github://juliendelplanque/JRPC/src' ] ]
]
